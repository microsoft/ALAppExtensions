namespace Microsoft.Integration.Shopify;

page 30137 "Shpfy Initial Import"
{
    Caption = 'Shopify Initial Import';
    PageType = Worksheet;
    SourceTable = "Shpfy Initial Import Line";
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the entity that was imported.';

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Rec."Page ID")
                    end;
                }
                field("Shop Code"; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shopify shop code.';

                    trigger OnDrillDown()
                    var
                        Shop: Record "Shpfy Shop";
                    begin
                        if Shop.Get(Rec."Shop Code") then
                            Page.RunModal(Page::"Shpfy Shop Card", Shop);
                    end;
                }
                field("Job Status"; Rec."Job Status")
                {
                    ApplicationArea = All;
                    StyleExpr = JobStatusStyle;
                    ToolTip = 'Specifies the status of the import job. ';

                    trigger OnDrillDown()
                    begin
                        InitialImport.ShowJobQueueLogEntry(Rec."Job Queue Entry ID");
                    end;
                }
                field(ActiveSession; InitialImport.IsActiveSession(Rec."Session ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Active Session';
                    ToolTip = 'Specifies whether the session is active.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        JobStatusStyle := InitialImport.GetStatusStyleExpression(Format(Rec."Job Status"));
    end;

    var
        InitialImport: Codeunit "Shpfy Initial Import";
        [InDataSet]
        JobStatusStyle: Text;
}