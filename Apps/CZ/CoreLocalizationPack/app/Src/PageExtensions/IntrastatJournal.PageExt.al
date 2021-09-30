pageextension 31139 "Intrastat Journal CZL" extends "Intrastat Journal"
{
    layout
    {
        addafter("Tariff No.")
        {
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication of the Intrastat journal line.';
            }
            field("Specific Movement CZL"; Rec."Specific Movement CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Specific movement code of the Intrastat journal line.';
            }
        }
#if CLEAN19
        moveafter("Country/Region Code"; "Country/Region of Origin Code")
        moveafter("Area"; "Shpt. Method Code")
#endif
        addafter("Supplementary Units")
        {
            field("Supplem. UoM Code CZL"; Rec."Supplem. UoM Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the supplementary unit of measure code for the Intrastat journal line. This number is assigned to an item.';
            }
            field("Supplem. UoM Quantity CZL"; Rec."Supplem. UoM Quantity CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the quantity converted to the supplementary UoM of the Intrastat journal line.';
            }
            field("Supplem. UoM Net Weight CZL"; Rec."Supplem. UoM Net Weight CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the netto weight converted to the supplementary UoM of the Intrastat journal line.';
            }
            field("Base Unit of Measure CZL"; Rec."Base Unit of Measure CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unit in which the item is held in inventory.';
            }
        }
        addafter("Internal Ref. No.")
        {
            field("Prev. Declaration No. CZL"; Rec."Prev. Declaration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the previous declaration number for the Intrastat journal line.';
            }
            field("Prev. Declaration Line No. CZL"; Rec."Prev. Declaration Line No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the declaration line number for the previous declaration for the Intrastat journal line.';
            }
            field("Additional Costs CZL"; Rec."Additional Costs CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether additional costs have been included in the transaction on the line.';
                Visible = false;
            }
            field("Source Entry Date CZL"; Rec."Source Entry Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source entry date of the intrastat journal line';
                Visible = false;
            }
        }
    }
    actions
    {
        modify(GetEntries)
        {
            Visible = false;
        }
        addfirst(processing)
        {
            action(GetEntriesCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Suggest Lines';
                Ellipsis = true;
                Image = SuggestLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Suggests Intrastat transactions to be reported and fills in Intrastat journal.';

                trigger OnAction()
                var
                    VATReportsConfiguration: Record "VAT Reports Configuration";
                    GetItemEntries: Report "Get Item Ledger Entries CZL";
                begin
                    VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Intrastat Report");
                    if VATReportsConfiguration.FindFirst() and (VATReportsConfiguration."Suggest Lines Codeunit ID" <> 0) then begin
                        Codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", Rec);
                        exit;
                    end;

                    GetItemEntries.SetIntrastatJnlLine(Rec);
                    GetItemEntries.RunModal();
                end;
            }
        }
#pragma warning disable AL0432
        addfirst(reporting)
#pragma warning restore AL0432
        {
            action("Test Report CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test Report';
                Ellipsis = true;
                Image = TestReport;
                ToolTip = 'Specifies test report';

                trigger OnAction()
                var
                    IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
                    TestReport: Report "Get Item Ldg. Entries Test CZL";
                begin
                    IntrastatJnlBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
                    TestReport.InitializeRequest(IntrastatJnlBatch.GetStatisticsStartDate());
                    TestReport.RunModal();
                end;
            }
        }
        addafter(CreateFile)
        {
            action(ExportCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export';
                Ellipsis = true;
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Allows the intrastat journal export do csv.';

                trigger OnAction()
                begin
                    Rec.ExportIntrastatJournalCZL(Rec);
                end;
            }

            action("Intrastat - Invoice Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat - Invoice Checklist';
                Ellipsis = true;
                Image = PrintChecklistReport;
                ToolTip = 'Open the report for intrastat - invoice checklist.';

                trigger OnAction()
                var
                    IntraJnlLine: Record "Intrastat Jnl. Line";
                begin
                    IntraJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    IntraJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    Report.Run(Report::"Intrastat - Invoice Check CZL", true, false, IntraJnlLine);
                end;
            }
        }
    }
}