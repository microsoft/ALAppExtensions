namespace Microsoft.DataMigration.API;

using Microsoft.Utilities;
using Microsoft.DataMigration;
using System.Environment;

page 40020 "Cloud Migration Companies API"
{
    PageType = API;
    SourceTable = "Hybrid Company";
    APIGroup = 'cloudMigration';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Cloud Migration Company';
    EntitySetCaption = 'Cloud Migration Companies';
    EntitySetName = 'cloudMigrationCompanies';
    EntityName = 'cloudMigrationCompany';
    DelayedInsert = true;
    Extensible = false;
    ODataKeyFields = "SystemId";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Id';
                }
                field(name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'name';
                }

                field(replicate; Rec."Replicate")
                {
                    Caption = 'Migrate';
                    ApplicationArea = All;
                }

                field(displayName; Rec."Display Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Display Name';
                }
                field(estimatedSize; Rec."Estimated Size")
                {
                    Caption = 'Estimated Size (GB)';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(status; Status)
                {
                    Caption = 'Status';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(created; Created)
                {
                    Caption = 'Created';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(companyInitializationStatus; Rec."Company Initialization Status")
                {
                    Caption = 'Company Initialization Status';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(companyInitializationError; CompanyInitializationFailureTxt)
                {
                    Caption = 'Company Initialization Error';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure CreateCompaniesMarkedForReplication(var ActionContext: WebServiceActionContext)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.CreateCompanies();
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InitializeCompany(var ActionContext: WebServiceActionContext)
    var
        HybridCompanyInitialize: Codeunit "Hybrid Company Initialize";
    begin
        HybridCompanyInitialize.InitalizeCompany(Rec);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;

    trigger OnAfterGetRecord()
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        Company: Record Company;
    begin
        Status := AssistedCompanySetupStatus.GetCompanySetupStatusValue(CopyStr(Rec.Name, 1, MaxStrLen(Company.Name)));
        Created := Company.Get(Rec.Name);
        if Rec."Company Initialization Status" = Rec."Company Initialization Status"::"Initialization Failed" then
            CompanyInitializationFailureTxt := Rec.GetCompanyInitFailureMessage()
        else
            Clear(CompanyInitializationFailureTxt);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(Status);
        Clear(Created);
    end;

    var
        Status: Enum "Company Setup Status";
        Created: Boolean;
        CompanyInitializationFailureTxt: Text;
}