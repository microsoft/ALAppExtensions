// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

#if not CLEAN26
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
#endif
using Microsoft.Inventory.Ledger;

tableextension 31054 "Direct Trans. Header CZL" extends "Direct Trans. Header"
{
#if not CLEANSCHEMA25
    fields
    {
        field(31000; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
    }
#endif
#if not CLEAN26
    var
        GlobalDocumentNo: Code[20];
        GlobalIsIntrastatTransaction: Boolean;

    [Obsolete('Pending removal. Use IsIntrastatTransactionCZ from Intrastat CZ extension instead.', '26.0')]
    procedure IsIntrastatTransactionCZL(): Boolean
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
#endif

    procedure GetRegisterUserIDCZL(): Code[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetFilterFromDirectTransHeaderCZL(Rec);
        if ItemLedgerEntry.FindFirst() then
            exit(ItemLedgerEntry.GetRegisterUserIDCZL());
    end;
#if not CLEAN26
    [Obsolete('Pending removal. Use OnBeforeIsIntrastatTransactionCZ from Intrastat CZ extension instead.', '26.0')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateGlobalIsIntrastatTransactionCZL(DirectTransHeader: Record "Direct Trans. Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
#endif
}
