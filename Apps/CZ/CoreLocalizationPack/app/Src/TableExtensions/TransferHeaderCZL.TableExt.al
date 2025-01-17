// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;

tableextension 31010 "Transfer Header CZL" extends "Transfer Header"
{
#if not CLEANSCHEMA25
    fields
    {
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
    }
#endif
    var
        GlobalDocumentNo: Code[20];
        GlobalIsIntrastatTransaction: Boolean;

    procedure IsIntrastatTransactionCZL() IsIntrastat: Boolean
    begin
        if ("No." <> GlobalDocumentNo) or ("No." = '') then begin
            GlobalDocumentNo := "No.";
            GlobalIsIntrastatTransaction := UpdateGlobalIsIntrastatTransaction();
        end;
        exit(GlobalIsIntrastatTransaction);
    end;

    local procedure UpdateGlobalIsIntrastatTransaction(): Boolean
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeUpdateGlobalIsIntrastatTransactionCZL(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if "Trsf.-from Country/Region Code" = "Trsf.-to Country/Region Code" then
            exit(false);

        CompanyInformation.Get();
        if "Trsf.-from Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastatCZL("Trsf.-to Country/Region Code", false));
        if "Trsf.-to Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastatCZL("Trsf.-from Country/Region Code", false));
        exit(false);
    end;

    procedure ShipOrReceiveInventoriableTypeItemsCZL(): Boolean
    var
        TransferLine: Record "Transfer Line";
        Item: Record Item;
    begin
        TransferLine.SetRange("Document No.", "No.");
        TransferLine.SetFilter("Item No.", '<>%1', '');
        if TransferLine.FindSet() then
            repeat
                if Item.Get(TransferLine."Item No.") then
                    if ((TransferLine."Qty. to Receive" <> 0) or (TransferLine."Qty. to Ship" <> 0)) and Item.IsInventoriableType() then
                        exit(true);
            until TransferLine.Next() = 0;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateGlobalIsIntrastatTransactionCZL(TransferHeader: Record "Transfer Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
