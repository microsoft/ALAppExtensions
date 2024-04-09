// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Reports;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Counting.Journal;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;

report 31073 "Phys. Inventory Document CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PhysInventoryDocument.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Physical Inventory Counting Document';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(CompanyInfo_Name; Name)
            {
                IncludeCaption = true;
            }
            column(CompanyInfo_Address; Address)
            {
                IncludeCaption = true;
            }
            column(CompanyInfo_City; City)
            {
            }
            column(CompanyInfo_Post_CodeAddress; "Post Code")
            {
            }
            column(CompanyInfo_VAT_Registration_No; "VAT Registration No.")
            {
                IncludeCaption = true;
            }
            column(CompanyInfo_Registration_No; "Registration No.")
            {
                IncludeCaption = true;
            }
            column(CompanyInfo_Tax_Registration_No; "Tax Registration No. CZL")
            {
                IncludeCaption = true;
            }
            column(DocumentNo; DocumentNo)
            {
            }
            column(PostingDate; Format(PostingDate))
            {
            }
            column(Reason; Reason)
            {
            }
            column(Members; Members)
            {
            }
            column(Location_Name; Location.Name)
            {
            }
            column(ReportFilter; ReportFilter)
            {
            }
            dataitem(PhysInvLedgEntry; "Phys. Inventory Ledger Entry")
            {
                RequestFilterFields = "Document No.", "Posting Date", "Location Code", "Item No.", "Variant Code";
                column(PhysInvLedgEntry_Item_No; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(PhysInvLedgEntry_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(PhysInvLedgEntry_Unit_of_Measure_Code; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
                column(PhysInvLedgEntry_Qty_Calculated; "Qty. (Calculated)")
                {
                    IncludeCaption = true;
                }
                column(PhysInvLedgEntry_Qty_Phys_Inventory; "Qty. (Phys. Inventory)")
                {
                    IncludeCaption = true;
                }
                column(PhysInvLedgEntry_QtyChange; "Qty. (Phys. Inventory)" - "Qty. (Calculated)")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(PhysInvLedgEntry_Unit_Cost; "Unit Cost")
                {
                    IncludeCaption = true;
                }
                column(PhysInvLedgEntry_ChangeCost; ChangeCost)
                {
                }
                column(PhysInvLedgEntry_CostChange; "Qty. (Calculated)" * "Unit Cost" + ChangeCost)
                {
                }
                column(ConfirmationText; StrSubstNo(ConfirmationTxt, PostingDate))
                {
                }
                column(Member1; Member[1])
                {
                }
                column(Member2; Member[2])
                {
                }
                column(Member3; Member[3])
                {
                }
                column(Member4; Member[4])
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Description = '' then
                        if Item.Get("Item No.") then
                            Description := Item.Description;
                    if Location.Code <> "Location Code" then
                        if not Location.Get("Location Code") then
                            Clear(Location);

                    ChangeCost := 0;
                    if "Qty. (Phys. Inventory)" - "Qty. (Calculated)" <> 0 then
                        ChangeCost := CalcChangeCost(PhysInvLedgEntry);
                end;
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
                    field(ReasonCZL; Reason)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document Reason';
                        ToolTip = 'Specifies the document reason.';
                    }
                    field("Member[1]"; Member[1])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '1. Persona';
                        ToolTip = 'Specifies an name from the Company Official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(0, CompanyOfficialCZL) = Action::LookupOK then
                                Member[1] := CompanyOfficialCZL.FullName();
                        end;
                    }
                    field("Member[2]"; Member[2])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '2. Persona';
                        ToolTip = 'Specifies an name from the Company Official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(0, CompanyOfficialCZL) = Action::LookupOK then
                                Member[2] := CompanyOfficialCZL.FullName();
                        end;
                    }
                    field("Member[3]"; Member[3])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '3. Persona';
                        ToolTip = 'Specifies an name from the Company Official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(0, CompanyOfficialCZL) = Action::LookupOK then
                                Member[3] := CompanyOfficialCZL.FullName();
                        end;
                    }
                    field("Member[4]"; Member[4])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '4. Persona';
                        ToolTip = 'Specifies an name from the Company Official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(0, CompanyOfficialCZL) = Action::LookupOK then
                                Member[4] := CompanyOfficialCZL.FullName();
                        end;
                    }
                }
            }
        }
    }
    labels
    {
        PageLbl = 'Page';
        DocumentLbl = 'Inventory Counting Document No.';
        InventoryDateLbl = 'Items as of';
        ReasonLbl = 'Reason';
        CommissionLbl = 'Commission';
        LocationLbl = 'Location';
        QtyChangeLbl = 'Qty. Change';
        CostChangeLbl = 'Cost Change';
        TotalItemAmountLbl = 'Total Item Amount';
        TotalPageLbl = 'Total statement page (Quantity, Amount)';
        TotalChangesLbl = 'Total changes (Quantity, Amount)';
        TotalStatementLbl = 'Total statement (Quantity, Amount)';
        ConfirmedLbl = 'Confirmed by manager';
    }

    trigger OnPreReport()
    var
        PhysInventoryLedgerEntry: Record "Phys. Inventory Ledger Entry";
    begin
        if PhysInvLedgEntry.GetRangeMin("Document No.") <> PhysInvLedgEntry.GetRangeMax("Document No.") then
            Error(SelectOnlyOneErr, PhysInvLedgEntry.FieldCaption("Document No."));
        DocumentNo := PhysInvLedgEntry.GetRangeMax("Document No.");
        if PhysInvLedgEntry.GetRangeMin("Posting Date") <> PhysInvLedgEntry.GetRangeMax("Posting Date") then
            Error(SelectOnlyOneErr, PhysInvLedgEntry.FieldCaption("Posting Date"));
        PostingDate := PhysInvLedgEntry.GetRangeMax("Posting Date");

        PhysInventoryLedgerEntry.CopyFilters(PhysInvLedgEntry);
        PhysInventoryLedgerEntry.SetRange("Document No.");
        PhysInventoryLedgerEntry.SetRange("Posting Date");
        ReportFilter := PhysInventoryLedgerEntry.GetFilters();

        if Member[1] <> '' then
            Members += Member[1];
        if Member[2] <> '' then
            if Members <> '' then
                Members += ', ' + Member[2]
            else
                Members := Member[2];
        if Member[3] <> '' then
            if Members <> '' then
                Members += ', ' + Member[3]
            else
                Members := Member[3];
        if Member[4] <> '' then
            if Members <> '' then
                Members += ', ' + Member[4]
            else
                Members := Member[4];
    end;

    var
        CompanyOfficialCZL: Record "Company Official CZL";
        Item: Record Item;
        Location: Record Location;
        Member: array[4] of Text[100];
        Reason: Text;
        DocumentNo: Code[20];
        ChangeCost: Decimal;
        Members: Text;
        PostingDate: Date;
        SelectOnlyOneErr: Label 'Please select only one %1.', Comment = '%1 = value to select in request page';
        ReportFilter: Text;
        ConfirmationTxt: Label 'We, signed this document, confirm inventory counting results on %1.', Comment = '%1 = document date';

    local procedure CalcChangeCost(PhysInventoryLedgerEntry: Record "Phys. Inventory Ledger Entry"): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ChangeCost2: Decimal;
        ChangeQty2: Decimal;
    begin
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Item No.");
        ItemLedgerEntry.SetRange("Document No.", PhysInventoryLedgerEntry."Document No.");
        ItemLedgerEntry.SetRange("Posting Date", PhysInventoryLedgerEntry."Posting Date");
        ItemLedgerEntry.SetRange("Item No.", PhysInventoryLedgerEntry."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", PhysInventoryLedgerEntry."Variant Code");
        ItemLedgerEntry.SetRange("Location Code", PhysInventoryLedgerEntry."Location Code");
        ItemLedgerEntry.SetRange("Entry Type", PhysInventoryLedgerEntry."Entry Type");
        case ItemLedgerEntry.Count() of
            0:
                ChangeCost2 := 0;
            1:
                begin
                    ItemLedgerEntry.FindFirst();
                    ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                    ChangeCost2 := ItemLedgerEntry."Cost Amount (Actual)";
                end;
            else begin
                ItemLedgerEntry.FindSet();
                repeat
                    ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                    ChangeCost2 += ItemLedgerEntry."Cost Amount (Actual)";
                    ChangeQty2 += ItemLedgerEntry.Quantity;
                until ItemLedgerEntry.Next() = 0;
                ChangeCost2 := Round(ChangeCost2 / ChangeQty2 *
                    (PhysInventoryLedgerEntry."Qty. (Phys. Inventory)" - PhysInventoryLedgerEntry."Qty. (Calculated)"), 0.01);
            end;
        end;
        exit(ChangeCost2);
    end;
}
