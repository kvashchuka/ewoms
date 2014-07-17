/*
  Copyright (C) 2009-2013 by Andreas Lauser

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
*/
/*!
 * \file
 *
 * \copydoc Ewoms::RichardsExtensiveQuantities
 */
#ifndef EWOMS_RICHARDS_EXTENSIVE_QUANTITIES_HH
#define EWOMS_RICHARDS_EXTENSIVE_QUANTITIES_HH

#include "richardsproperties.hh"

#include <ewoms/models/common/multiphasebaseextensivequantities.hh>

namespace Ewoms {

/*!
 * \ingroup RichardsModel
 * \ingroup ExtensiveQuantities
 *
 * \brief Calculates and stores the data which is required to
 *        calculate the flux of fluid over a face of a finite volume.
 */
template <class TypeTag>
class RichardsExtensiveQuantities
    : public MultiPhaseBaseExtensiveQuantities<TypeTag>
{
};

} // namespace Ewoms

#endif