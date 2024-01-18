// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Bank.Reconciliation;
using System.Utilities;

page 6121 "E-Document"
{
    ApplicationArea = Basic, Suite;
    PageType = Card;
    SourceTable = "E-Document";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    AdditionalSearchTerms = 'Edoc,Electronic Document';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Record; RecordLinkTxt)
                {
                    Caption = 'Record';
                    Editable = false;
                    ToolTip = 'Specifies the record, document, journal line, or ledger entry, that is linked to the electronic document.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowRecord();
                        CurrPage.Update();
                    end;
                }
                field(Direction; Rec.Direction)
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the direction of the electronic document.';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the Workflow used on the electronic document.';
                }
                field("Incoming E-Document No."; Rec."Incoming E-Document No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document number.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document type.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the document number of the electronic document.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the document date of the electronic document.';
                    Importance = Additional;
                }
                field("Due Date"; Rec."Due Date")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the due date of the electronic document.';
                }
                field("Order No."; Rec."Order No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the related order number of the electronic document.';
                    Importance = Additional;
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the total amount of the electronic document excluding VAT.';
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ToolTip = 'Specifies the total amount of the electronic document including VAT.';
                    Importance = Additional;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document currency code.';
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the customer/vendor of the electronic document.';
                }
                field("Bill-to/Pay-to Name"; Rec."Bill-to/Pay-to Name")
                {
                    ToolTip = 'Specifies the customer/vendor name of the electronic document.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document posting date.';
                }
                field("Electronic Document Status"; Rec.Status)
                {
                    Editable = false;
                    ToolTip = 'Specifies the status of the electronic document.';
                }
            }
            group(ReceivingCompanyInfo)
            {
                Caption = 'Receiving Company Information';
                Visible = Rec.Direction = Rec.Direction::Incoming;

                field("Receiving Company VAT Reg. No."; Rec."Receiving Company VAT Reg. No.")
                {
                    Caption = 'VAT Registration No.';
                    Editable = false;
                    ToolTip = 'Specifies the receiving company VAT number.';
                }
                field("Receiving Company GLN"; Rec."Receiving Company GLN")
                {
                    Caption = 'GLN';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the receiving company GLN.';
                }
                field("Receiving Company Name"; Rec."Receiving Company Name")
                {
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the receiving company name.';
                }
                field("Receiving Company Address"; Rec."Receiving Company Address")
                {
                    Caption = 'Address';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the receiving company address.';
                }
            }
            group(EDocServiceStatus)
            {
                ShowCaption = false;
                part(EdocoumentServiceStatus; "E-Document Service Status")
                {
                    SubPageLink = "E-Document Entry No" = field("Entry No");
                    ShowFilter = false;
                }
            }
            group("Errors and Warnings")
            {
                ShowCaption = false;
                part(ErrorMessagesPart; "Error Messages Part")
                {
                    Caption = 'Errors and Warnings';
                    ShowFilter = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Outgoing)
            {
                Caption = 'Outgoing';
                action(Send)
                {
                    Caption = 'Send Document';
                    ToolTip = 'Starts the document export.';
                    Image = SendElectronicDocument;
                    Visible = Rec.Direction = Rec.Direction::Outgoing;

                    trigger OnAction()
                    begin
                        SendEDocument();
                    end;
                }
                action(Recreate)
                {
                    Caption = 'Recreate Document';
                    ToolTip = 'Recreates the electronic document';
                    Image = CreateDocument;
                    Visible = Rec.Direction = Rec.Direction::Outgoing;

                    trigger OnAction()
                    var
                        EDocService: Record "E-Document Service";
                        EDocExport: Codeunit "E-Doc. Export";
                        EDocServices: Page "E-Document Services";
                    begin
                        EDocServices.LookupMode := true;
                        if EDocServices.RunModal() = Action::LookupOK then begin
                            EDocServices.GetRecord(EDocService);
                            EDocumentErrorHelper.ClearErrorMessages(Rec);
                            EDocExport.Recreate(Rec, EDocService);
                        end
                    end;
                }
                action(GetApproval)
                {
                    Caption = 'Get Approval';
                    ToolTip = 'Gets if the electronic document is approved or rejected';
                    Image = Approval;
                    Visible = Rec.Direction = Rec.Direction::Outgoing;

                    trigger OnAction()
                    var
                        EDocService: Record "E-Document Service";
                        EDocServices: Page "E-Document Services";
                    begin
                        EDocServices.LookupMode := true;
                        if EDocServices.RunModal() = Action::LookupOK then begin
                            EDocServices.GetRecord(EDocService);
                            EDocumentErrorHelper.ClearErrorMessages(Rec);
                            EDocIntegrationManagement.GetApproval(Rec, EDocService);
                        end
                    end;
                }
                action(Cancel)
                {
                    Caption = 'Cancel EDocument';
                    ToolTip = 'Cancels the electronic document';
                    Image = Cancel;
                    Visible = Rec.Direction = Rec.Direction::Outgoing;

                    trigger OnAction()
                    var
                        EDocService: Record "E-Document Service";
                        EDocServices: Page "E-Document Services";
                    begin
                        EDocServices.LookupMode := true;
                        if EDocServices.RunModal() = Action::LookupOK then begin
                            EDocServices.GetRecord(EDocService);
                            EDocumentErrorHelper.ClearErrorMessages(Rec);
                            EDocIntegrationManagement.Cancel(Rec, EDocService);
                        end
                    end;
                }
            }
            group(Incoming)
            {
                Caption = 'Incoming';
                action(ImportManually)
                {
                    Caption = 'Import Manually';
                    ToolTip = 'Imports the electronic document manually.';
                    Image = Import;
                    Visible = Rec.Direction = Rec.Direction::Incoming;

                    trigger OnAction()
                    begin
                        EDocImport.UploadDocument(Rec);
                    end;
                }
                action(GetBasicInfo)
                {
                    Caption = 'Get Basic Info';
                    ToolTip = 'Gets the electronic document basic info.';
                    Image = GetOrder;
                    Visible = Rec.Direction = Rec.Direction::Incoming;

                    trigger OnAction()
                    begin
                        EDocImport.GetBasicInfo(Rec);
                    end;
                }
                action(CreateDocument)
                {
                    Caption = 'Create Document';
                    ToolTip = 'Creates the document based on imported electronic document.';
                    Image = CreateDocument;
                    Visible = Rec.Direction = Rec.Direction::Incoming;

                    trigger OnAction()
                    begin
                        EDocImport.ProcessDocument(Rec, false, false);
                    end;
                }
                action(CreateJournal)
                {
                    Caption = 'Create Journal';
                    ToolTip = 'Creates the journal line.';
                    Image = Journal;
                    Visible = Rec.Direction = Rec.Direction::Incoming;

                    trigger OnAction()
                    begin
                        EDocImport.ProcessDocument(Rec, false, true);
                    end;
                }
                action(UpdateOrder)
                {
                    Caption = 'Update Order';
                    ToolTip = 'Updates related order.';
                    Image = UpdateDescription;
                    Visible = Rec.Direction = Rec.Direction::Incoming;

                    trigger OnAction()
                    begin
                        EDocImport.ProcessDocument(Rec, true, false);
                    end;
                }
                action(TextToAccountMapping)
                {
                    Caption = 'Map Text to Account';
                    Image = MapAccounts;
                    RunObject = Page "Text-to-Account Mapping Wksh.";
                    ToolTip = 'Create a mapping of text on electronic documents to identical text on specific debit, credit, and balancing accounts in the general ledger or on bank accounts so that the resulting document or journal lines are prefilled with the specified information.';
                    Visible = Rec.Direction = Rec.Direction::Incoming;
                }
            }
            action(EDocumentLog)
            {
                Caption = 'Logs';
                ToolTip = 'Shows all logs for the E-Document.';
                Image = Log;
                RunObject = Page "E-Document Logs";
                RunPageLink = "E-Doc. Entry No" = field("Entry No");
                RunPageMode = View;
            }
        }
        area(Promoted)
        {
            group(Out)
            {
                Caption = 'Outgoing';
                actionref(Send_Promoted; Send) { }
                actionref(Recreate_Promoted; Recreate) { }
                actionref(Cancel_promoteed; Cancel) { }
                actionref(Approval_promoteed; GetApproval) { }
            }
            group(In)
            {
                Caption = 'Incoming';
                actionref(ImportManually_Promoted; ImportManually) { }
                actionref(GetBasicInfo_Promoted; GetBasicInfo) { }
                group(CreateDoc)
                {
                    ShowAs = SplitButton;
                    actionref(CreateDocument_Promoted; CreateDocument) { }
                    actionref(CreateJournal_Promoted; CreateJournal) { }
                    actionref(UpdateOrder_Promoted; UpdateOrder) { }
                }
                actionref(TextToAccountMapping_Promoted; TextToAccountMapping) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RecordLinkTxt := EDocumentHelper.GetRecordLinkText(Rec);
        ShowErrors();
    end;

    local procedure ShowErrors()
    var
        ErrorMessage: Record "Error Message";
        TempErrorMessage: Record "Error Message" temporary;
    begin
        ErrorMessage.SetRange("Context Record ID", Rec.RecordId);
        ErrorMessage.CopyToTemp(TempErrorMessage);
        CurrPage.ErrorMessagesPart.Page.SetRecords(TempErrorMessage);
        CurrPage.ErrorMessagesPart.Page.Update(false);
    end;

    local procedure SendEDocument()
    var
        EDocService: Record "E-Document Service";
        EDocServices: Page "E-Document Services";
        IsAsync: Boolean;
    begin
        EDocServices.LookupMode(true);
        if EDocServices.RunModal() <> Action::LookupOK then
            exit;
        EDocServices.GetRecord(EDocService);
        EDocumentErrorHelper.ClearErrorMessages(Rec);
        if not EDocIntegrationManagement.Send(Rec, EDocService, IsAsync) then
            exit;
        if IsAsync then
            EDocumentBackgroundjobs.GetEDocumentResponse();
    end;

    var
        EDocumentBackgroundjobs: Codeunit "E-Document Background Jobs";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentHelper: Codeunit "E-Document Processing";
        RecordLinkTxt: Text;
}
