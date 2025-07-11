// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18004 "GST General Ledger Setup Ext" extends "General Ledger Setup"
{
    layout
    {
        addafter("Application")
        {
            group("Tax Information")
            {
                group("GST")
                {
                    field("State Code - Kerala"; Rec."State Code - Kerala")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the state code that will be used to GST calculation of Kerala Cess.';
                    }
                    field("GST Distribution Nos."; Rec."GST Distribution Nos.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the code for the number series that will be used to assign numbers to GST distribution.';
                    }
                    field("GST Credit Adj. Jnl Nos."; Rec."GST Credit Adj. Jnl Nos.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the code for the number series that will be used to assign numbers to GST credit adjustment journal.';
                    }
                    field("GST Settlement Nos."; Rec."GST Settlement Nos.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the code for the number series that will be used to assign numbers to GST settlement.';
                    }
                    field("GST Recon. Tolerance"; Rec."GST Recon. Tolerance")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the tolerance level for GST reconciliation.';
                    }
                    field("Generate E-Inv. on Sales Post"; Rec."Generate E-Inv. on Sales Post")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the function through which e-invoice will be generated at the time of sale post.';
                    }
                    field("Custom Duty Component Code"; Rec."Custom Duty Component Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the component code of custom duty.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GSTSetup: Record "GST Setup";
                            TaxComponent: Record "Tax Component";
                        begin
                            if not GSTSetup.Get() then
                                exit;
                            TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                            if Page.RunModal(0, TaxComponent) = Action::LookupOK then
                                Rec.Validate("Custom Duty Component Code", TaxComponent.Name);
                        end;

                        trigger OnValidate()
                        var
                            GSTSetup: Record "GST Setup";
                            TaxComponent: Record "Tax Component";
                        begin
                            if Rec."Custom Duty Component Code" <> '' then begin
                                if not GSTSetup.Get() then
                                    exit;
                                TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                                TaxComponent.SetRange(Name, Rec."Custom Duty Component Code");
                                if TaxComponent.IsEmpty() then
                                    Rec.FieldError("Custom Duty Component Code");
                            end;
                        end;
                    }
                    field("GST Opening Account"; Rec."GST Opening Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies GST Opening general ledger account number to be used for Opening Entries.';
                    }
                    field("Sub-Con Interim Account"; Rec."Sub-Con Interim Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies Sub-con interim general ledger account number where the entry will be posted.';
                    }
                }
            }
        }
    }
}
