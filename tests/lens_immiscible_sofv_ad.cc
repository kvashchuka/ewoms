// -*- mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
// vi: set et ts=4 sw=4 sts=4:
/*
  This file is part of the Open Porous Media project (OPM).

  OPM is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 2 of the License, or
  (at your option) any later version.

  OPM is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with OPM.  If not, see <http://www.gnu.org/licenses/>.

  Consult the COPYING file in the top-level source directory of this
  module for the precise wording of the license and the list of
  copyright holders.
*/
/*!
 * \file
 *
 * \brief Two-phase test for the immiscible model which uses the element-centered finite
 *        volume discretization in conjunction with automatic differentiation
 */
#include "config.h"

#include <ewoms/common/start.hh>

#include <ewoms/models/immiscible/immisciblemodel.hh>
#include <ewoms/disc/sofv/sofvdiscretization.hh>
#include "problems/lensproblem.hh"

namespace Ewoms {
namespace Properties {
NEW_TYPE_TAG(LensProblemSofvAd, INHERITS_FROM(ImmiscibleTwoPhaseModel, LensBaseProblem));

// use the element centered finite volume spatial discretization
SET_TAG_PROP(LensProblemSofvAd, SpatialDiscretizationSplice, SofvDiscretization);

// use automatic differentiation for this simulator
SET_TAG_PROP(LensProblemSofvAd, LocalLinearizerSplice, AutoDiffLocalLinearizer);
}}


int main(int argc, char **argv)
{
    typedef TTAG(LensProblemSofvAd) ProblemTypeTag;
    return Ewoms::start<ProblemTypeTag>(argc, argv);
}
