
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.Utilities;

page 6328 "Emission Source Setup"
{
    Caption = 'Emission Source Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Emission Source Setup";

    layout
    {
        area(Content)
        {
            repeater(SourceSetup)
            {
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprTxt;
                }
                field("Country Name"; Rec."Country Name")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprTxt;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprTxt;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprTxt;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprTxt;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(File)
            {
                Caption = 'File';

                action(AddFile)
                {
                    ApplicationArea = All;
                    Image = Add;
                    Caption = 'Upload File';
                    ToolTip = 'Upload a new file';

                    trigger OnAction()
                    begin
                        Rec.AddFile();
                    end;
                }
                action(Download)
                {
                    ApplicationArea = All;
                    Image = Download;
                    Caption = 'Download File';
                    ToolTip = 'Download the selected file.';

                    trigger OnAction()
                    begin
                        Rec.DownloadFile();
                    end;
                }

                action(Delete)
                {
                    ApplicationArea = All;
                    Image = Delete;
                    Caption = 'Delete File';
                    ToolTip = 'Delete the file.';

                    trigger OnAction()
                    var
                        EmissionSourceSetup: Record "Emission Source Setup";
                        SourceCO2Emission: Record "Source CO2 Emission";
                        ConfirmMgt: Codeunit "Confirm Management";
                        DeleteQst: Label 'Go ahead and delete the file?';
                        NoFileErr: Label 'No file to delete';
                    begin
                        Rec.CalcFields("Source File");
                        if not Rec."Source File".HasValue then
                            Error(NoFileErr);

                        if not ConfirmMgt.GetResponse(DeleteQst, false) then
                            exit;

                        EmissionSourceSetup := Rec;
                        CurrPage.SetSelectionFilter(EmissionSourceSetup);
                        Clear(EmissionSourceSetup."Source File");
                        EmissionSourceSetup.Description := '';
                        EmissionSourceSetup.Modify(true);
                        SourceCO2Emission.SetRange("Emission Source ID", EmissionSourceSetup.Id);
                        SourceCO2Emission.DeleteAll(true);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(AddFile_Promoted; AddFile)
                {
                }
                actionref(Download_Promoted; Download)
                {
                }
                actionref(Delete_Promoted; Delete)
                {
                }
            }
        }
    }

    var
        StyleExprTxt: Text;

    trigger OnAfterGetRecord()
    begin
        CalculateStyleExpr();
    end;

    local procedure CalculateStyleExpr()
    begin
        if (Rec."Ending Date" <> 0D) and (Rec."Ending Date" < WorkDate()) then
            StyleExprTxt := 'Unfavorable'
        else
            StyleExprTxt := '';
    end;
}