// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31221 "Contoso General Ledger CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Gen. Journal Template" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertGeneralJournalTemplate(Name: Code[10]; Description: Text[80]; Type: Enum "Gen. Journal Template Type"; Recurring: Boolean; NoSeries: Code[20]; AllowVATDifference: Boolean; PostingReportId: Integer)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        Exists: Boolean;
    begin
        if GenJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalTemplate.Validate(Name, Name);
        GenJournalTemplate.Validate(Description, Description);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Validate(Recurring, Recurring);
        GenJournalTemplate.Validate("Allow VAT Difference", AllowVATDifference);
        GenJournalTemplate.Validate("Posting Report ID", PostingReportId);

        if Recurring then
            GenJournalTemplate.Validate("Posting No. Series", NoSeries)
        else
            GenJournalTemplate.Validate("No. Series", NoSeries);

        if Exists then
            GenJournalTemplate.Modify(true)
        else
            GenJournalTemplate.Insert(true);
    end;
}
