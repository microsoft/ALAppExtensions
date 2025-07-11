// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using System.Reflection;

page 18280 "GST Component Mapping Recon."
{
    Caption = 'GST Component Mapping Recon.';
    PageType = List;
    SourceTable = "GST Recon. Mapping";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies unique code to identify the  components. For example, CGST/SGST/UTGST/CESS/IGST';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GSTSetup: Record "GST Setup";
                        TaxComponent: Record "Tax Component";
                    begin
                        if not GSTSetup.Get() then
                            exit;
                        TaxComponent.Reset();
                        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                        if Page.RunModal(0, TaxComponent) = Action::LookupOK then
                            Rec.Validate("GST Component Code", TaxComponent.Name);
                    end;

                    trigger OnValidate()
                    var
                        GSTSetup: Record "GST Setup";
                        TaxComponent: Record "Tax Component";
                    begin
                        if Rec."GST Component Code" <> '' then begin
                            if not GSTSetup.get() then
                                exit;
                            TaxComponent.Reset();
                            TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                            TaxComponent.SetRange(Name, Rec."GST Component Code");
                            if TaxComponent.IsEmpty() then
                                Rec.FieldError("GST Component Code");
                        end;
                    end;
                }
                field("GST Reconciliation Field No."; Rec."GST Reconciliation Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component wise field numbers to map with the defined GST component code.';

                    trigger OnAssistEdit()
                    var
                        Field: Record Field;
                        GSTReconMapping: Record "GST Recon. Mapping";
                        FieldMapErr: Label 'The field %1 is already selected.', Comment = 'The field %1 is already selected.';
                    begin
                        if Page.RunModal(Page::"GST Recon. Field Mapping", Field) = Action::LookupOK then begin
                            Rec."GST Reconciliation Field No." := Field."No.";
                            Rec."GST Reconciliation Field Name" := Field.FieldName;
                            GSTReconMapping.SetRange("GST Reconciliation Field No.", Rec."GST Reconciliation Field No.");
                            if not GSTReconMapping.IsEmpty() then
                                Error(FieldMapErr, Rec."GST Reconciliation Field No.");
                        end;
                    end;
                }
                field("GST Reconciliation Field Name"; Rec."GST Reconciliation Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the GST reconciliation field number.';
                }
                field("ISD Ledger Field No."; Rec."ISD Ledger Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the input service distribution ledger field number for distributed amount.';
                }
                field("ISD Ledger Field Name"; Rec."ISD Ledger Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the input service distribution ledger name of input service distribution ledger field number.';
                }
            }
        }
    }
}
