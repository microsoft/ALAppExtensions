// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13665 "OIOUBL-IssuedFinChrgMemoList" extends "Issued Fin. Charge Memo List"
{
    actions
    {
        addafter(Statistics)
        {
            separator(Seperator) { }

            action(CreateEletronicDoc)
            {
                Caption = 'Create Electronic Finance Charge Memo';
                Tooltip = 'Create an electronic version of the current document.';
                Promoted = true;
                ApplicationArea = Basic, Suite;
                Image = ElectronicDoc;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
                begin
                    IssuedFinChargeMemoHeader := Rec;
                    IssuedFinChargeMemoHeader.SETRECFILTER();

                    REPORT.RUNMODAL(REPORT::"OIOUBL-Create E-Fin Chrg Memos", TRUE, FALSE, IssuedFinChargeMemoHeader);
                end;
            }
        }
    }
}