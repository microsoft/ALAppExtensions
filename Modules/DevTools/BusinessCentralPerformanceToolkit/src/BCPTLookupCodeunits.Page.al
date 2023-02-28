// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
page 149005 "BCPT Lookup Codeunits"
{
    Caption = 'Lookup Codeunits';
    PageType = List;
    SourceTable = "Codeunit Metadata";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the test codeunit.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the test codeunit.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowAll)
            {
                ApplicationArea = All;
                Caption = 'Show/Hide All';
                Image = Filter;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Show or hide all.';

                trigger OnAction()
                begin
                    ShowAllCodeunits := not ShowAllCodeunits;
                    if ShowAllCodeunits then
                        Rec.SetRange(TableNo)
                    else
                        Rec.SetRange(TableNo, Database::"BCPT Line");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    Begin
        StatusDialog.Open(OpenLbl);
        DlgOpened := true;
        Rec.SetFilter(ID, '49000..99999|149100..149999');
        Rec.FilterGroup(2);
        Rec.SetFilter(ID, '>=50000&<>%1', Codeunit::"BCPT Role Wrapper");
        Rec.SetFilter(SubType, '%1|%2', Rec.SubType::Normal, Rec.SubType::Test);
        Rec.FilterGroup(0);
    End;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if DlgOpened then
            StatusDialog.Close();
        DlgOpened := false;
        exit(Rec.Find(Which));
    end;

    var
        ShowAllCodeunits: Boolean;
        DlgOpened: boolean;
        StatusDialog: Dialog;
        OpenLbl: Label 'Retrieving test objects. This may take a couple of minutes the first time...';
}