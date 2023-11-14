// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Projects.Project.Ledger;

report 31007 "Get Item Ldg. Entries Test CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GetItemLdgEntriesTest.rdl';
    Caption = 'Get Item Ledger Entries - Test';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    dataset
    {
        dataitem("Country/Region"; "Country/Region")
        {
            DataItemTableView = sorting("Intrastat Code") where("Intrastat Code" = filter(<> ''));
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Country/Region Code" = field(Code);
                DataItemTableView = sorting("Country/Region Code", "Entry Type", "Posting Date") where("Entry Type" = filter(Purchase | Sale | Transfer));

                trigger OnAfterGetRecord()
                begin
                    IntrastatJnlLine2.SetRange("Source Entry No.", "Entry No.");
                    if IntrastatJnlLine2.FindFirst() or (CompanyInformation."Country/Region Code" = "Country/Region Code") then
                        CurrReport.Skip();

                    if IntrastatJnlLine2.FindFirst() then
                        CurrReport.Skip();

                    IntrastatJnlLine2.SetRange("Source Entry No.", "Entry No.");
                    BufferItemWhenEmptyTariffNo("Item No.");
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Posting Date", StartDate, EndDate);
                    IntrastatJnlLine2.SetCurrentKey("Source Type", "Source Entry No.");
                    IntrastatJnlLine2.SetRange("Source Type", IntrastatJnlLine2."Source Type"::"Item Entry");
                end;
            }
            dataitem("Job Ledger Entry"; "Job Ledger Entry")
            {
                DataItemLink = "Country/Region Code" = field(Code);
                DataItemTableView = sorting(Type, "Entry Type", "Country/Region Code", "Source Code", "Posting Date") where(Type = const(Item), "Source Code" = filter(<> ''));

                trigger OnAfterGetRecord()
                begin
                    IntrastatJnlLine2.SetRange("Source Entry No.", "Entry No.");
                    if IntrastatJnlLine2.FindFirst() or (CompanyInformation."Country/Region Code" = "Country/Region Code") then
                        CurrReport.Skip();
                    BufferItemWhenEmptyTariffNo("No.");
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Posting Date", StartDate, EndDate);
                    IntrastatJnlLine2.SetCurrentKey("Source Type", "Source Entry No.");
                    IntrastatJnlLine2.SetRange("Source Type", IntrastatJnlLine2."Source Type"::"Job Entry");
                end;
            }
        }
        dataitem(TempItem; "Item")
        {
            DataItemTableView = sorting("No.");
            UseTemporary = true;
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(No_TempItem; TempItem."No.")
            {
                IncludeCaption = true;
            }
            column(Description_TempItem; TempItem.Description)
            {
                IncludeCaption = true;
            }
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting date';
                    }
                    field(EndingDate; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date in the period.';
                    }
                }
            }
        }
    }

    labels
    {
        PageLbl = 'Page';
        ReportNameLbl = 'Get Item Ledger Entries - Test';
        ErrorCaptionLbl = 'Error description';
        ErrorDescriptionLbl = 'Tariff No. is not filled on the Item card!';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        IntrastatJnlLine2: Record "Intrastat Jnl. Line";
        CheckedItemsList: List of [Code[20]];
        StartDate: Date;
        EndDate: Date;

    procedure InitializeRequest(NewStartDate: Date)
    begin
        StartDate := NewStartDate;
        EndDate := CalcDate('<CM>', StartDate);
    end;

    local procedure BufferItemWhenEmptyTariffNo(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if CheckedItemsList.Contains(ItemNo) then
            exit;
        CheckedItemsList.Add(ItemNo);
        Item.Get(ItemNo);
        if Item."Tariff No." <> '' then
            exit;
        TempItem.Init();
        TempItem."No." := Item."No.";
        TempItem.Description := Item.Description;
        TempItem.Insert();
    end;
}
#endif
