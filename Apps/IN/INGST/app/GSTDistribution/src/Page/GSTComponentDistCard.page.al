// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 18201 "GST Component Dist. Card"
{
    PageType = Card;
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;
    PromotedActionCategories = 'New,Process,Report,New Document,Approve,Request Approval,Prices and Discounts,Navigate,Customer';
    RefreshOnActivate = true;
    SourceTable = "GST Component Distribution";
    Caption = 'GST Component Dist. Card';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Standard;
                    ToolTip = 'Specifies GST component code for input service distribution.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GSTSetup: Record "GST Setup";
                        TaxComponent: Record "Tax Component";
                    begin
                        if not GSTSetup.Get() then
                            exit;
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
                            if not GSTSetup.Get() then
                                exit;
                            TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                            TaxComponent.SetRange(Name, Rec."GST Component Code");
                            if TaxComponent.IsEmpty() then
                                Rec.FieldError("GST Component Code");
                        end;
                    end;
                }
                field("Distribution Component Code"; Rec."Distribution Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Standard;
                    ToolTip = 'Specifies distribution component code for input service distribution.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GSTSetup: Record "GST Setup";
                        TaxComponent: Record "Tax Component";
                    begin
                        if not GSTSetup.Get() then
                            exit;
                        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                        if Page.RunModal(0, TaxComponent) = Action::LookupOK then
                            Rec.Validate("Distribution Component Code", TaxComponent.Name);
                    end;

                    trigger OnValidate()
                    var
                        GSTSetup: Record "GST Setup";
                        TaxComponent: Record "Tax Component";
                    begin
                        if Rec."Distribution Component Code" <> '' then begin
                            if not GSTSetup.Get() then
                                exit;
                            TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                            TaxComponent.SetRange(Name, Rec."Distribution Component Code");
                            if TaxComponent.IsEmpty() then
                                Rec.FieldError("Distribution Component Code");
                        end;
                    end;
                }
                field("Intrastate Distribution"; Rec."Intrastate Distribution")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Standard;
                    ToolTip = 'Specifies whether intrastate distribution is applicable or not.';
                }
                field("Interstate Distribution"; Rec."Interstate Distribution")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Standard;
                    ToolTip = 'Specifies whether interstate distribution is applicable or not.';
                }
            }
        }
    }
}
