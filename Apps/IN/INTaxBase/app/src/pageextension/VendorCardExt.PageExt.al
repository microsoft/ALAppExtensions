// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 18554 "VendorCardExt" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field("State Code"; Rec."State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the State Code of Vendor';
            }
        }
        addafter(Receiving)
        {
            group("Tax Information")
            {
                field("Assessee Code"; Rec."Assessee Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Assessee Code by whom any tax or sum of money is payable';
                }
                group("PAN Details")
                {
                    field("P.A.N. No."; Rec."P.A.N. No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = PANNoEditable;
                        ToolTip = 'Specifies the Permanent Account No. of Party';
                    }
                    field("P.A.N. Status"; Rec."P.A.N. Status")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the PAN Status as PANAPPLIED,PANNOTAVBL,PANINVALID';

                        trigger OnValidate()
                        begin
                            PANStatusOnAfterValidate();
                        end;
                    }
                    field("P.A.N. Reference No."; Rec."P.A.N. Reference No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the PAN Reference No. in case the PAN is not available or applied by the party';
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PANStatusOnAfterValidate();
    end;

    trigger OnOpenPage()
    begin
        PANStatusOnAfterValidate();
    end;

    var
        PANNoEditable: Boolean;

    local procedure PANStatusOnAfterValidate()
    begin
        if Rec."P.A.N. Status" <> Rec."P.A.N. Status"::" " then
            PANNoEditable := false
        else
            PANNoEditable := true;
    end;
}
