// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface "Shpfy ICompany Mapping."
/// </summary>
interface "Shpfy ICompany Mapping"
{
    procedure DoMapping(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
}