namespace Microsoft.DataMigration;

using System.Environment;
using System.Reflection;

page 40064 "Cloud Migration Sanitize Table"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions = tabledata Company = r;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                ShowCaption = false;

                field(CompanyName; Company.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Company name';
                    TableRelation = Company.Name;
                    ToolTip = 'Specifies the company name of the table to be sanitized.';
                }
                field(TableId; TableMetadata.ID)
                {
                    ApplicationArea = All;
                    Caption = 'Table Id';
                    ToolTip = 'Specifies the ID of the table to be sanitized.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "All Objects";
                    begin
                        AllObj.SetFilter("Object Type", '%1|%2', AllObj."Object Type"::Table, AllObj."Object Type"::"TableExtension");
                        AllObjects.SetTableView(AllObj);
                        AllObjects.LookupMode(true);
                        if not (AllObjects.RunModal() in [Action::OK, Action::LookupOK]) then
                            exit(false);

                        AllObjects.GetRecord(AllObj);
                        TableMetadata.ID := AllObj."Object ID";
                        Text := Format(TableMetadata.ID);
                        exit(true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SanitizeTable)
            {
                ApplicationArea = All;
                Caption = 'Sanitize table';
                ToolTip = 'Invoke this action to sanitize the data in the code fields so they can be used in the product for the selected company and table. Invoke-NAVSanitizeField action should be used instead before cloud migration. If that was not done, this action can help to solve the issue.';
                Image = CheckList;

                trigger OnAction()
                var
                    HybridDeployment: Codeunit "Hybrid Deployment";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    Company.TestField(Company.Name);
                    TableMetadata.TestField(TableMetadata.ID);

                    HybridDeployment.SanitizeFields(Company.Name, TableMetadata.ID);
                    HybridCloudManagement.RepairCompanionTables();
                    Message(DataWasSanitizedMsg);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Promoted actions for Cloud Migration page.';
                actionref(SanitizeTable_Promoted; SanitizeTable)
                {
                }
            }
        }
    }

    var
        Company: Record Company;
        TableMetadata: Record "Table Metadata";
        DataWasSanitizedMsg: Label 'The data was sanitized for the selected table.';
}