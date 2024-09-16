namespace Microsoft.SubscriptionBilling;

page 8036 "Usage Data Blobs"
{
    SourceTable = "Usage Data Blob";
    Caption = 'Usage Data Blobs';
    PageType = List;
    LinksAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the sequential number assigned to the record when it was created.';
                }
                field("Usage Data Import Entry No."; Rec."Usage Data Import Entry No.")
                {
                    ToolTip = 'Specifies the sequential number of the related import that was assigned to it when it was created.';
                }
                field("Supplier No."; UsageDataImport."Supplier No.")
                {
                    Caption = 'Supplier No.';
                    ToolTip = 'Specifies the number of the supplier to which this usage data refers.';
                }
                field("Supplier Description"; UsageDataImport."Supplier Description")
                {
                    Caption = 'Supplier Description';
                    ToolTip = 'Specifies he description of the supplier to which this usage data refers.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the import.';
                }
                field("Import Date"; Rec."Import Date")
                {
                    ToolTip = 'Specifies the date of the import.';
                }
                field("Import Status"; Rec."Import Status")
                {
                    ToolTip = 'Specifies the status of the import.';
                }
                field("Reason (Preview)"; Rec."Reason (Preview)")
                {
                    ToolTip = 'Specifies the preview why the import failed.';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowReason();
                    end;
                }
                field(Source; Rec.Source)
                {
                    ToolTip = 'Specifies the file name of the import file.';
                }
                field("Data Hash Value"; Rec."Data Hash Value")
                {
                    ToolTip = 'Specifies the hash value of the file.';
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        UsageDataImport.Get(Rec."Usage Data Import Entry No.");
    end;

    var
        UsageDataImport: Record "Usage Data Import";
}
