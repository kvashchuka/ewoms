// $Id: 2p2cniproperties.hh 3784 2010-06-24 13:43:57Z bernd $
/*****************************************************************************
 *   Copyright (C) 2008-2010 by Andreas Lauser                               *
 *   Copyright (C) 2008-2009 by Melanie Darcis                               *
 *   Copyright (C) 2008-2009 by Klaus Mosthaf                                *
 *   Copyright (C) 2008-2009 by Bernd Flemisch                               *
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
 * \brief Defines the indices used by the 2p2cni box model
 */
#ifndef DUMUX_2P2CNI_INDICES_HH
#define DUMUX_2P2CNI_INDICES_HH

#include <dumux/boxmodels/2p2c/2p2cindices.hh>

namespace Dumux
{
/*!
 * \addtogroup TwoPTwoCNIModel
 */
// \{

/*!
 * \brief Enumerations for the non-isothermal 2-phase 2-component model
 */
template <class TypeTag, int formulation, int PVOffset>
class TwoPTwoCNIIndices : public TwoPTwoCIndices<TypeTag, formulation, PVOffset>
{
public:
    static const int temperatureIdx = PVOffset + 2; //! The index for temperature in primary variable vectors.
    static const int energyEqIdx = PVOffset + 2; //! The index for energy in equation vectors.
};

}
#endif
