// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 10532 "MTD Return Details"
{
    Caption = 'Submitted VAT Returns';
    Editable = false;
    PageType = ListPart;
    SourceTable = "MTD Return Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("VAT Due Sales"; "VAT Due Sales")
                {
                    ToolTip = 'Specifies the VAT due on sales and other outputs. This corresponds to box 1 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                }
                field("VAT Due Acquisitions"; "VAT Due Acquisitions")
                {
                    ToolTip = 'Specifies the VAT due on acquisitions from other EC Member States. This corresponds to box 2 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                }
                field("Total VAT Due"; "Total VAT Due")
                {
                    ToolTip = 'Specifies the total VAT due (the sum of "VAT Due Sales" and "VAT Due Acquisitions"). This corresponds to box 3 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                }
                field("VAT Reclaimed Curr Period"; "VAT Reclaimed Curr Period")
                {
                    ToolTip = 'Specifies the VAT reclaimed on purchases and other inputs (including acquisitions from the EC). This corresponds to box 4 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                }
                field("Net VAT Due"; "Net VAT Due")
                {
                    ToolTip = 'Specifies the difference between "Total VAT Due" and "VAT Reclaimed Curr Period". This corresponds to box 5 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                }
                field("Total Value Sales Excl. VAT"; "Total Value Sales Excl. VAT")
                {
                    ToolTip = 'Specifies the yotal value of sales and all other outputs excluding any VAT. This corresponds to box 6 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 0;
                }
                field("Total Value Purchases Excl.VAT"; "Total Value Purchases Excl.VAT")
                {
                    ToolTip = 'Specifies the total value of purchases and all other inputs excluding any VAT (including exempt purchases). This corresponds to box 7 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 0;
                }
                field("Total Value Goods Suppl. ExVAT"; "Total Value Goods Suppl. ExVAT")
                {
                    ToolTip = 'Specifies the total value of all supplies of goods and related costs, excluding any VAT, to other EC member states. This corresponds to box 8 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 0;
                }
                field("Total Acquisitions Excl. VAT"; "Total Acquisitions Excl. VAT")
                {
                    ToolTip = 'Specifies the total value of acquisitions of goods and related costs excluding any VAT, from other EC member states. This corresponds to box 9 on the VAT Return form.';
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 0;
                }
            }
        }
    }

    actions
    {
    }
}

