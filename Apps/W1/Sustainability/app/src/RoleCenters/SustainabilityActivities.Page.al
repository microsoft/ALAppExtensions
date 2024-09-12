namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.EServices.EDocument;
using Microsoft.Purchases.Document;
using System.Device;
using Microsoft.Sustainability.Ledger;

page 6236 "Sustainability Activities"
{
    PageType = CardPart;
    SourceTable = "Sustainability Cue";
    RefreshOnActivate = true;
    Caption = 'Activities';

    layout
    {
        area(Content)
        {
            cuegroup(General)
            {
                CuegroupLayout = Wide;
                ShowCaption = false;
                field("Emission CO2"; Rec."Emission CO2")
                {
                    ApplicationArea = All;
                    Caption = 'CO2 This Month';
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the CO2 This Month field.';
                }
                field("Emission CH4"; Rec."Emission CH4")
                {
                    ApplicationArea = All;
                    Caption = 'CH4 This Month';
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the CH4 This Month field.';
                }
                field("Emission N2O"; Rec."Emission N2O")
                {
                    ApplicationArea = All;
                    Caption = 'N2O This Month';
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the N2O This Month field.';
                }
            }
            cuegroup("Ongoing Purchases")
            {
                Caption = 'Ongoing Purchases';
                field("Ongoing Purchase Orders"; Rec."Ongoing Purchase Orders")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies purchases orders that are not posted or only partially posted.';
                }
                field("Ongoing Purchase Invoices"; Rec."Ongoing Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Purchase Invoices";
                    ToolTip = 'Specifies purchases invoices that are not posted or only partially posted.';
                }
                field("Purch. Invoices Due Next Week"; Rec."Purch. Invoices Due Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of payments to vendors that are due next week.';
                }
            }
            cuegroup("Incoming Documents")
            {
                Caption = 'Incoming Documents';
                field("My Incoming Documents"; Rec."My Incoming Documents")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies incoming documents that are assigned to you.';
                }
                field("Awaiting Verfication"; Rec."Inc. Doc. Awaiting Verfication")
                {
                    ApplicationArea = Suite;
                    DrillDown = true;
                    ToolTip = 'Specifies incoming documents in OCR processing that require you to log on to the OCR service website to manually verify the OCR values before the documents can be received.';
                    Visible = ShowAwaitingIncomingDoc;

                    trigger OnDrillDown()
                    var
                        OCRServiceSetup: Record "OCR Service Setup";
                    begin
                        if not OCRServiceSetup.Get() then
                            exit;

                        if OCRServiceSetup.Enabled then
                            HyperLink(OCRServiceSetup."Sign-in URL");
                    end;
                }
            }
            cuegroup(Camera)
            {
                Caption = 'Scan documents';
                Visible = HasCamera;

                actions
                {
                    action(CreateIncomingDocumentFromCamera)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Create Incoming Doc. from Camera';
                        Image = TileCamera;
                        ToolTip = 'Create an incoming document by taking a photo of the document with your device camera. The photo will be attached to the new document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                            Camera: Codeunit Camera;
                            InStr: InStream;
                            PictureName: Text;
                        begin
                            if not Camera.GetPicture(InStr, PictureName) then
                                exit;

                            IncomingDocument.CreateIncomingDocument(InStr, PictureName);
                            CurrPage.Update();
                        end;
                    }
                }
            }
        }
    }

    var
        HasCamera: Boolean;
        ShowAwaitingIncomingDoc: Boolean;

    trigger OnOpenPage()
    var
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
        Camera: Codeunit Camera;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        ShowAwaitingIncomingDoc := OCRServiceMgt.OcrServiceIsEnable();
        HasCamera := Camera.IsAvailable();

        ApplyDateFilter();
    end;

    local procedure ApplyDateFilter()
    begin
        Rec.SetRange("Date Filter", CalcDate('<-CM>', WorkDate()), CalcDate('<CM>', WorkDate()));
        Rec.CalcFields("Emission CO2", "Emission CH4", "Emission N2O");

        Rec.SetFilter("Due Next Week Filter", '%1..%2', CalcDate('<1D>', WorkDate()), CalcDate('<1W>', WorkDate()));
    end;
}