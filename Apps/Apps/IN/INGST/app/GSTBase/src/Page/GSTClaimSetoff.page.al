// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 18010 "GST Claim Setoff"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "GST Claim Setoff";
    Caption = 'GST Claim Setoff';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component code for which set off component to be defined';

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
                field("Set Off Component Code"; Rec."Set Off Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the component defined as per GST Settlement Priority.';
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
                            Rec.Validate("Set Off Component Code", TaxComponent.Name);
                    end;

                    trigger OnValidate()
                    var
                        GSTSetup: Record "GST Setup";
                        TaxComponent: Record "Tax Component";
                    begin
                        if Rec."Set Off Component Code" <> '' then begin
                            if not GSTSetup.get() then
                                exit;
                            TaxComponent.Reset();
                            TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                            TaxComponent.SetRange(Name, Rec."Set Off Component Code");
                            if TaxComponent.IsEmpty() then
                                Rec.FieldError("Set Off Component Code");
                        end;
                    end;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies  the component priority for GST settlement';
                }
            }
        }
    }
}
