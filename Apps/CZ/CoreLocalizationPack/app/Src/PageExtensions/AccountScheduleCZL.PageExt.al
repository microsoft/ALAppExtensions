// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.GeneralLedger.Account;

pageextension 11782 "Account Schedule CZL" extends "Account Schedule"
{
    layout
    {
        addfirst(Control1)
        {
            field("Row Correction CZL"; Rec."Row Correction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the row code for the correction.';
                Visible = false;

                trigger OnLookup(var Text: Text): Boolean
                var
                    AccScheduleLine: Record "Acc. Schedule Line";
                begin
                    AccScheduleLine.SetRange("Schedule Name", Rec."Schedule Name");
                    AccScheduleLine.SetFilter("Row No.", '<>%1', Rec."Row No.");
                    if Page.RunModal(Page::"Acc. Schedule Line List CZL", AccScheduleLine) = Action::LookupOK then
                        Rec."Row Correction CZL" := AccScheduleLine."Row No.";
                end;
            }
            field("Source Table CZL"; Rec."Source Table CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the selected source table (VAT entry, Value entry, Customer or vendor entry).';
            }
        }
        addafter(Show)
        {
            field("Calc CZL"; Rec."Calc CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies when the value can be calculated in the Account Schedule - Always, Never, When Positive, When Negative.';
            }
        }
        addlast(Control1)
        {
            field("Assets/Liabilities Type CZL"; Rec."Assets/Liabilities Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the assets or liabilities type for the account schedule line.';
                Visible = false;
            }
        }
        modify(Totaling)
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
                AccSchedManagement: Codeunit "AccSchedManagement";
                GLAccountList: Page "G/L Account List";
                AccScheduleExtensionsCZL: Page "Acc. Schedule Extensions CZL";
            begin
                if Rec."Totaling Type" in [Rec."Totaling Type"::"Posting Accounts", Rec."Totaling Type"::"Total Accounts"] then begin
                    GLAccountList.LookupMode(true);
                    if not (GLAccountList.RunModal() = Action::LookupOK) then
                        exit(false);

                    Text := GLAccountList.GetSelectionFilter();
                    exit(true);
                end;

                if Rec."Totaling Type" = Rec."Totaling Type"::"Custom CZL" then begin
                    if Rec.Totaling <> '' then begin
                        AccScheduleExtensionCZL.SetFilter(Code, Rec.Totaling);
                        AccScheduleExtensionCZL.FindFirst();
                        AccScheduleExtensionsCZL.SetRecord(AccScheduleExtensionCZL);
                    end;
                    AccScheduleExtensionsCZL.SetLedgType(Rec."Source Table CZL");
                    AccScheduleExtensionsCZL.LookupMode(true);
                    if not (AccScheduleExtensionsCZL.RunModal() = Action::LookupOK) then
                        exit(false);

                    AccScheduleExtensionsCZL.GetRecord(AccScheduleExtensionCZL);
                    Text := AccScheduleExtensionCZL.Code;
                    exit(true);
                end;

                Rec.LookupTotaling();
                if Rec."Totaling Type" = Rec."Totaling Type"::"Account Category" then
                    Text := AccSchedManagement.GLAccCategoryText(Rec)
                else
                    Text := Rec.Totaling;

                exit(true);

            end;
        }
    }
}
