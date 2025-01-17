// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Service.Item;
using Microsoft.Integration.D365Sales;
using System.Environment.Configuration;

#pragma warning disable AS0130
#pragma warning disable PTE0025
page 6611 "FS Customer Asset List"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    ApplicationArea = Suite;
    Caption = 'Customer Assets - Dynamics 365 Field Service';
    Editable = false;
    PageType = List;
    SourceTable = "FS Customer Asset";
    SourceTableView = sorting(Name);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Suite;
                    Caption = 'Name';
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies the customer asset name.';
                }
                field(AssetTag; Rec.AssetTag)
                {
                    ApplicationArea = Suite;
                    Caption = 'Asset Tag';
                    ToolTip = 'Specifies the customer asset tag.';
                }
                field(CustomerAssetCategoryName; Rec.CustomerAssetCategoryName)
                {
                    ApplicationArea = Suite;
                    Caption = 'Category';
                    ToolTip = 'Specifies the customer asset category name. ';
                }
                field(CustomerName; CustomerName)
                {
                    ApplicationArea = Suite;
                    Caption = 'Category';
                    ToolTip = 'Specifies the name of the customer. ';
                }
                field(Coupled; Coupled)
                {
                    ApplicationArea = Suite;
                    Caption = 'Coupled';
                    ToolTip = 'Specifies if the Dynamics 365 Field Service record is coupled to Business Central.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CreateFromFS)
            {
                ApplicationArea = Suite;
                Caption = 'Create in Business Central';
                Image = NewItemNonStock;
                ToolTip = 'Generate the entity from the Field Service customer asset.';
                Visible = ShowCreateInBC;

                trigger OnAction()
                var
                    FSCustomerAsset: Record "FS Customer Asset";
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CurrPage.SetSelectionFilter(FSCustomerAsset);
                    CRMIntegrationManagement.CreateNewRecordsFromSelectedCRMRecords(FSCustomerAsset);
                end;
            }
            action(ShowOnlyUncoupled)
            {
                ApplicationArea = Suite;
                Caption = 'Hide Coupled Records';
                Image = FilterLines;
                ToolTip = 'Do not show coupled records.';

                trigger OnAction()
                begin
                    Rec.MarkedOnly(true);
                end;
            }
            action(ShowAll)
            {
                ApplicationArea = Suite;
                Caption = 'Show Coupled Records';
                Image = ClearFilter;
                ToolTip = 'Show coupled records.';

                trigger OnAction()
                begin
                    Rec.MarkedOnly(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CreateFromFS_Promoted; CreateFromFS)
                {
                }
                actionref(ShowOnlyUncoupled_Promoted; ShowOnlyUncoupled)
                {
                }
                actionref(ShowAll_Promoted; ShowAll)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMAccount: Record "CRM Account";
        RecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(Rec.CustomerAssetId, Database::"Service Item", RecordID) then
            if CurrentlyCoupledFSCustomerAsset.CustomerAssetId = Rec.CustomerAssetId then begin
                Coupled := 'Current';
                FirstColumnStyle := 'Strong';
                Rec.Mark(true);
            end else begin
                Coupled := 'Yes';
                FirstColumnStyle := 'Subordinate';
                Rec.Mark(false);
            end
        else begin
            Coupled := 'No';
            FirstColumnStyle := 'None';
            Rec.Mark(true);
        end;
        if CRMAccount.Get(Rec.Account) then
            CustomerName := CRMAccount.Name
        else
            CustomerName := '';
    end;

    trigger OnInit()
    begin
        Codeunit.Run(Codeunit::"CRM Integration Management");
    end;

    trigger OnOpenPage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        LookupCRMTables: Codeunit "Lookup CRM Tables";
    begin
        Rec.FilterGroup(4);
        Rec.SetView(LookupCRMTables.GetIntegrationTableMappingView(Database::"FS Customer Asset"));
        Rec.FilterGroup(0);
        ShowCreateInBC := ApplicationAreaMgmtFacade.IsPremiumExperienceEnabled();
    end;

    var
        CurrentlyCoupledFSCustomerAsset: Record "FS Customer Asset";
        Coupled: Text;
        FirstColumnStyle: Text;
        CustomerName: Text;
        ShowCreateInBC: Boolean;

    procedure SetCurrentlyCoupledFSCustomerAsset(FSCustomerAsset: Record "FS Customer Asset")
    begin
        CurrentlyCoupledFSCustomerAsset := FSCustomerAsset;
    end;
}

