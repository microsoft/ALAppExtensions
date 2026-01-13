// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment;

page 10071 "IRS Forms Company Selector"
{
    Caption = 'Companies';
    PageType = List;
    SourceTable = Company;
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                field(SelectedOption; Selected)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                    ToolTip = 'Specifies whether the company is selected.';

                    trigger OnValidate()
                    begin
                        if Selected then begin
                            TempSelectedCompany.Name := Rec.Name;
                            TempSelectedCompany.Insert();
                        end else begin
                            TempSelectedCompany.Get(Rec.Name);
                            TempSelectedCompany.Delete();
                        end;
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company name';
                    Editable = false;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company display name';
                    Editable = false;
                }
            }
        }
    }

    var
        TempSelectedCompany: Record Company temporary;
        Selected: Boolean;

    trigger OnOpenPage()
    var
        CompanyRec: Record Company;
    begin
        CompanyRec.FindSet();
        repeat
            Rec.Name := CompanyRec.Name;
            Rec.Insert();
        until CompanyRec.Next() = 0;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateSelectedOptionOnThePage();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateSelectedOptionOnThePage();
    end;

    procedure SetSelectedCompanies(var NewTempSelectedCompany: Record Company temporary)
    begin
        TempSelectedCompany.Reset();
        TempSelectedCompany.DeleteAll();
        NewTempSelectedCompany.Reset();
        if NewTempSelectedCompany.IsEmpty() then
            exit;
        NewTempSelectedCompany.FindSet();
        repeat
            TempSelectedCompany.Name := NewTempSelectedCompany.Name;
            TempSelectedCompany.Insert();
        until NewTempSelectedCompany.Next() = 0;
    end;

    procedure GetSelectedCompanies(var NewTempSelectedCompany: Record Company temporary)
    begin
        NewTempSelectedCompany.Reset();
        NewTempSelectedCompany.DeleteAll();
        TempSelectedCompany.Reset();
        if not TempSelectedCompany.FindSet() then
            exit;
        repeat
            NewTempSelectedCompany.Name := TempSelectedCompany.Name;
            NewTempSelectedCompany.Insert();
        until TempSelectedCompany.Next() = 0;
    end;

    local procedure UpdateSelectedOptionOnThePage()
    begin
        Selected := TempSelectedCompany.Get(Rec.Name);
    end;
}
