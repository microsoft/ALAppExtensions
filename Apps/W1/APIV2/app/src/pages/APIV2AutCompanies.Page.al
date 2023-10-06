namespace Microsoft.API.V2;

using System.Environment;

page 30001 "APIV2 - Aut. Companies"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Automation Company';
    EntitySetCaption = 'Automation Companies';
    DelayedInsert = true;
    EntityName = 'automationCompany';
    EntitySetName = 'automationCompanies';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = Company;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                    Editable = false;
                }
                field(evaluationCompany; Rec."Evaluation Company")
                {
                    Caption = 'Evaluation Company';
                    Editable = false;
                }
                field(displayName; Rec."Display Name")
                {
                    Caption = 'Display Name';
                    NotBlank = true;
                }
                field(businessProfileId; Rec."Business Profile Id")
                {
                    Caption = 'Business ProfileId';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Name := COPYSTR(Rec."Display Name", 1, MAXSTRLEN(Rec.Name));
        Rec."Evaluation Company" := false;
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}

