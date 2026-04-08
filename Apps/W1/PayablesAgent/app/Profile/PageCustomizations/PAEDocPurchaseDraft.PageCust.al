// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;

pagecustomization "PA E-Doc. Purchase Draft" customizes "E-Document Purchase Draft"
{
    ClearActions = true;
    ClearLayout = true;

    layout
    {
        modify("Vendor No.")
        {
            Visible = true;
        }
        modify("Vendor Name")
        {
            Visible = true;
        }
        modify("Vendor Address")
        {
            Visible = true;
        }
        modify(Record)
        {
            Visible = true;
        }
        modify(DraftType)
        {
            Visible = true;
        }
        modify(Lines)
        {
            Visible = true;
        }
    }
    actions
    {
        modify(ViewExtractedDocumentData)
        {
            Visible = true;
        }
        modify(CreateDocument)
        {
            Visible = true;
        }
        modify(Vendors)
        {
            Visible = true;
        }
        modify(OpenVendorList)
        {
            Visible = true;
        }
        modify(HistoricalVendorMatches)
        {
            Visible = true;
        }
        modify(CreateVendorAction)
        {
            Visible = true;
        }
    }
}