/*****************************************************************************
 *   Copyright (C) 2008 by Andreas Lauser, Bernd Flemisch                    *
 *   Institute of Hydraulic Engineering                                      *
 *   University of Stuttgart, Germany                                        *
 *   email: <givenname>.<name>@iws.uni-stuttgart.de                          *
 *                                                                           *
 *   This program is free software; you can redistribute it and/or modify    *
 *   it under the terms of the GNU General Public License as published by    *
 *   the Free Software Foundation; either version 2 of the License, or       *
 *   (at your option) any later version, as long as this copyright notice    *
 *   is included in its original form.                                       *
 *                                                                           *
 *   This program is distributed WITHOUT ANY WARRANTY.                       *
 *****************************************************************************/
/*!
 * \file
 *
 * \brief Implementation of a regularized version of van Genuchten's
 *        capillary pressure <-> saturation relation.
 */
#ifndef REGULARIZED_VAN_GENUCHTEN_HH
#define REGULARIZED_VAN_GENUCHTEN_HH

#include <dumux/new_material/vangenuchten.hh>
#include <dumux/new_material/regularizedvangenuchtencontext.hh>

#include <algorithm>

#include <math.h>
#include <assert.h>

namespace Dune
{
/*!\ingroup material
 *
 * \brief Implementation of a regularized version of van Genuchten's
 *        capillary pressure <-> saturation relation.
 *
 * This class bundles the "raw" curves as static members and doesn't
 * concern itself converting absolute to effective saturations and
 * vince versa.
 */
template <class ContextT>
class RegularizedVanGenuchten
{
public:
    typedef ContextT Context;
    typedef typename Context::Scalar Scalar;

    typedef Dune::VanGenuchten<ContextT> VanGenuchten;

    /*!
     * \brief The capillary pressure-saturation curve.
     *
     * Van Genuchten's empirical capillary pressure <-> saturation
     * function is given by
     * \f[
     p_C = (\overline{S}_w^{-1/m} - 1)^{1/n}/\alpha
     \f]
     * \param Swe Effective saturation of of the wetting phase \f$\overline{S}_w\f$
     */
    static Scalar pC(const Context &context, Scalar Swe)
    {
        // make sure that the capilarry pressure observes a
        // derivative != 0 for 'illegal' saturations. This is
        // required for example by newton solvers (if the
        // derivative calculated numerically) in order to get the
        // saturation moving to the right direction if it
        // temporarily is in an 'illegal' range.
        if (Swe <= SweLow_) {
            return VanGenuchten::pC(context, SweLow_/2) + mLow_(context)*(Swe - SweLow_/2);
        }
        else if (Swe >= SweHigh_) {
            return VanGenuchten::pC(context, SweHigh_) + mHigh_(context)*(Swe - SweHigh_);
        }

        // if the effective saturation is in an 'reasonable'
        // range, we use the real van genuchten law...
        return VanGenuchten::pC(context, Swe);
    }

    /*!
     * \brief The saturation-capillary pressure curve.
     *
     * This is the inverse of the capillary pressure-saturation curve:
     * \f[
     \overline{S}_w = {p_C}^{-1} = ((\alpha p_C)^n + 1)^{-m}
     \f]
     *
     * \param pC Capillary pressure \f$\p_C\f$
     * \return The effective saturaion of the wetting phase \f$\overline{S}_w\f$
     */
    static Scalar Sw(const Context &context, Scalar pC)
    {
        // calculate the saturation which corrosponds to the
        // saturation in the non-regularized verision of van
        // Genuchten's law
        Scalar Swe;
        if (pC <= 0)
            // make sure we invert the regularization
            Swe = 1.5; 
        else
            Swe = VanGenuchten::Sw(context, pC);

        // invert the regularization if necessary
        if (Swe <= SweLow_) {
            // invert the low saturation regularization of pC()
            Scalar pC_SweLow2 = VanGenuchten::pC(context, SweLow_/2);
            return (pC - pC_SweLow2)/mLow_(context) + SweLow_/2;
        }
        else if (Swe >= SweHigh_) {
            // invert the high saturation regularization of pC()
            Scalar pC_SweHigh = VanGenuchten::pC(context, SweHigh_);
            return (pC - pC_SweHigh)/mHigh_(context) + SweHigh_;
        }

        return Swe;
    }

    /*!
     * \brief Returns the partial derivative of the capillary
     *        pressure to the effective saturation.
     *
     * This is equivalent to
     * \f[
     \frac{\partial p_C}{\partial \overline{S}_w} =
     -\frac{1}{\alpha} (\overline{S}_w^{-1/m} - 1)^{1/n - }
     \overline{S}_w^{-1/m} / \overline{S}_w / m
     \f]
    */
    static Scalar dpC_dSw(const Context &context, Scalar Swe)
    {
        // derivative of the regualarization
        if (Swe <= SweLow_) {
            // the slope of the straight line used in pC()
            return mLow_(context);
        }
        else if (Swe >= SweHigh_) {
            // the slope of the straight line used in pC()
            return mHigh_(context);
        }

        return VanGenuchten::dpC_dSw(context, Swe);
    }

    /*!
     * \brief Returns the partial derivative of the effective
     *        saturation to the capillary pressure.
     */
    static Scalar dSw_dpC(const Context &context, Scalar pC)
    {
        // calculate the saturation which corrosponds to the
        // saturation in the non-regularized verision of van
        // Genuchten's law
        Scalar Swe;
        if (pC < 0)
            Swe = 1.5; // make sure we regularize below
        else
            Swe = VanGenuchten::Sw(context, pC);

        // derivative of the regularization
        if (Swe <= SweLow_) {
            // same as in dpC_dSw() but inverted
            return 1/mLow_(context);
        }
        else if (Swe >= SweHigh_) {
            // same as in dpC_dSw() but inverted
            return 1/mHigh_(context);
        }

        return VanGenuchten::dSw_dpC(context, pC);
    }

    /*!
     * \brief The relative permeability for the wetting phase of
     *        the medium implied by van Genuchten's
     *        parameterization.
     *
     * \param Sw_mob The mobile saturation of the wetting phase.
     */
    static Scalar krw(const Context &context, Scalar Sw_mob)
    {
        if (Sw_mob < 0)
            return 0;
        else if (Sw_mob > 1)
            return 1;

        return VanGenuchten::krw(context, Sw_mob);
    };

    /*!
     * \brief The relative permeability for the non-wetting phase
     *        of the medium implied by van Genuchten's
     *        parameterization.
     *
     * \param Sw_mob The mobile saturation of the wetting phase.
     */
    static Scalar krn(const Context &context, Scalar Sw_mob)
    {
        if (Sw_mob <= 0)
            return 1;
        else if (Sw_mob >= 1)
            return 0;

        return VanGenuchten::krn(context, Sw_mob);
    }

private:
    // the slope of the straight line used to regularize saturations
    // below the minimum saturation
    static Scalar mLow_(const Context &context)
    {
        Scalar pC_SweLow  = VanGenuchten::pC(context, SweLow_);
        Scalar pC_SweLow2 = VanGenuchten::pC(context, SweLow_/2);
        return (pC_SweLow - pC_SweLow2) / (SweLow_ - SweLow_/2);
    }

    // the slope of the straight line used to regularize saturations
    // above the maximum saturation
    static Scalar mHigh_(const Context &context)
    {
        Scalar pC_SweHigh = VanGenuchten::pC(context, SweHigh_);
        return (0 - pC_SweHigh)/(1.0 - SweHigh_);
    }

    static const Scalar SweLow_;
    static const Scalar SweHigh_;
};

template <class ContextT>
const typename ContextT::Scalar RegularizedVanGenuchten<ContextT>::SweLow_(0.03);
template <class ContextT>
const typename ContextT::Scalar RegularizedVanGenuchten<ContextT>::SweHigh_(0.97);
}

#endif
