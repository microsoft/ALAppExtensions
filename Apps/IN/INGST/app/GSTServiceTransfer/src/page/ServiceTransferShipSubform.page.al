// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;

page 18360 "Service Transfer Ship Subform"
{
    AutoSplitKey = true;
    Caption = 'Service Transfer Ship Subform';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Service Transfer Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transfer From G/L Account No."; Rec."Transfer From G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the service general ledger account to which service transfer shipment value will be posted.';
                }
                field("Transfer Price"; Rec."Transfer Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of service shipped.';

                    trigger OnValidate()
                    var
                        TaxCaseExecution: Codeunit "Use Case Execution";
                    begin
                        CurrPage.SaveRecord();
                        TaxCaseExecution.HandleEvent('OnAfterTransferPrireUpdate', Rec, '', 0);
                    end;
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Group code for the calculation of GST on Service line.';
                }
                field("SAC Code"; Rec."SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SAC code for the calculation of GST on Service line.';
                }
                field(Shipped; Rec.Shipped)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction has been shipped or not.';
                }
                field(Exempted; Rec.Exempted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the shipment line is exempted from GST.';
                }
                field("Ship Control A/C No."; Rec."Ship Control A/C No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies general ledger account number which will be used for ship control.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the code for global dimension 1, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the code for global dimension 2, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Line)
            {
                Caption = 'Line';
                action(Dimensions)
                {
                    AccessByPermission = TableData "Dimension" = R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = Dimensions;
                    ToolTip = 'Dimensions (Shift+Ctrl+D)';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
            }
        }
    }
}
