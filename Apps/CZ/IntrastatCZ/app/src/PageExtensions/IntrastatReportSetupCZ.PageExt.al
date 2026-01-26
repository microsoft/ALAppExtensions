// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 31342 "Intrastat Report Setup CZ" extends "Intrastat Report Setup"
{
    layout
    {
        addafter("Default Trans. Type - Returns")
        {
            field("Def. Phys. Trans. - Returns CZ"; Rec."Def. Phys. Trans. - Returns CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the default value of the Physical Movement field for sales returns and service returns, and purchase returns.';
            }
        }
        addafter("Def. Country/Region Code")
        {
            field("No Item Charges in Int. CZ"; Rec."No Item Charges in Int. CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the no item charge in intrastat.';
            }
            field("Intrastat Rounding Type CZ"; Rec."Intrastat Rounding Type CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the rounding type for amount calculation for Intrastat declaration.';
            }
        }
#if not CLEAN26
        addafter(Numbering)
        {
            group("Mandatory Fields")
            {
                Caption = 'Mandatory Fields';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                ObsoleteReason = 'This group is moved to Intrastat Core extension.';

                field("Transaction Type Mandatory CZ"; Rec."Transaction Type Mandatory CZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies this option to make transaction type specification mandatory.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    ObsoleteReason = 'This field is moved to Intrastat Core extension.';
                }
                field("Transaction Spec. Mandatory CZ"; Rec."Transaction Spec. Mandatory CZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you are using a mandatory transaction specification for reporting.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    ObsoleteReason = 'This field is moved to Intrastat Core extension.';
                }
                field("Transport Method Mandatory CZ"; Rec."Transport Method Mandatory CZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies this option to make transport method specification mandatory.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    ObsoleteReason = 'This field is moved to Intrastat Core extension.';
                }
                field("Shipment Method Mandatory CZ"; Rec."Shipment Method Mandatory CZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies this option to make shipment method specification mandatory.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    ObsoleteReason = 'This field is moved to Intrastat Core extension.';
                }
            }
        }
#endif
    }
}