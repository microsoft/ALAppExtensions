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
#if not CLEAN22
    actions
    {
        addafter("F&unctions")
        {
            group("Other CZL")
            {
                Caption = 'O&ther';
                Visible = false;
                ObsoleteReason = 'The group will be removed.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';

                action("Set up Custom Functions CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set up Custom Functions';
                    Ellipsis = true;
                    Image = NewSum;
                    RunObject = page "Acc. Schedule Extensions CZL";
                    ToolTip = 'Specifies acc. schedule extensions page';
                    ObsoleteReason = 'The action is moved to Financial Reports.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                }
                action("File Mapping CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'File Mapping';
                    Image = ExportToExcel;
                    ToolTip = 'File Mapping allows to set up export to Excel. You can see three dots next to the field with Amount.';
                    ObsoleteReason = 'The action is moved to Financial Reports.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';

                    trigger OnAction()
                    var
                        AccScheduleFileMappingCZL: Page "Acc. Schedule File Mapping CZL";
                    begin
                        AccScheduleFileMappingCZL.SetAccSchedName(Rec."Schedule Name");
                        AccScheduleFileMappingCZL.RunModal();
                    end;
                }
            }
        }
        addlast(processing)
        {
            group("Results Group CZL")
            {
                Caption = 'Results';
                Visible = false;
                ObsoleteReason = 'The group will be removed.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                action("Save Results CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Save Results';
                    Ellipsis = true;
                    Image = Save;
                    ToolTip = 'Opens window for saving results of acc. schedule';
                    ObsoleteReason = 'The action is moved to Financial Reports.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';

                    trigger OnAction()
                    var
                        AccSchedExtensionMgtCZL: Codeunit "Acc. Sched. Extension Mgt. CZL";
                    begin
                        AccSchedExtensionMgtCZL.CreateResults(Rec, '', false);
                    end;
                }
                action("Results CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Results';
                    Image = ViewDetails;
                    RunObject = page "Acc. Sched. Res. Hdr. List CZL";
                    RunPageLink = "Acc. Schedule Name" = field("Schedule Name");
                    ToolTip = 'Opens acc. schedule res. header list';
                    ObsoleteReason = 'The action is moved to Financial Reports.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                }
            }

        }
    }
#endif
}
