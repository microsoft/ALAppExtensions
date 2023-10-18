namespace Microsoft.API.V1;

using System.Environment;

page 20001 "APIV1 - Aut. Companies"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'automationCompany', Locked = true;
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
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(name; Rec.Name)
                {
                    Caption = 'name', Locked = true;
                    Editable = false;
                }
                field(evaluationCompany; Rec."Evaluation Company")
                {
                    Caption = 'evaluationCompany', Locked = true;
                    Editable = false;
                }
                field(displayName; Rec."Display Name")
                {
                    Caption = 'displayName', Locked = true;
                    NotBlank = true;
                }
                field(businessProfileId; Rec."Business Profile Id")
                {
                    Caption = 'businessProfileId', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Name := CopyStr(Rec."Display Name", 1, MaxStrLen(Rec.Name));
        Rec."Evaluation Company" := false;
    end;

    trigger OnOpenPage()
    begin
        BINDSUBSCRIPTION(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}


