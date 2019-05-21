// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13627 "OIOUBL-Sales Post Print Sub."
{
    // TODO
    // [EventSubscriber(ObjectType::Codeunit,Codeunit::"Sales-Post + Print",'OnBeforeSalesPostPrint','',false,false)]
    // procedure OnBeforeSalesPostPrint(var SalesSetup : Record "Sales & Receivables Setup";var SalesHeader : Record "Sales Header";var SendReportAsEmail : Boolean;var SubscriberInvoked : Boolean)
    // var
    //     SalesPostViaJobQueue : Codeunit "Sales Post via Job Queue";
    //     SalesPostPrint : Codeunit "Sales-Post + Print";
    // begin
    //     if SalesSetup."Post & Print with Job Queue" AND NOT SendReportAsEmail AND (SalesHeader."OIOUBL-GLN" = '') then
    //         SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
    //     else  begin
    //         if SalesHeader."OIOUBL-GLN" <> '' then
    //             SalesSetup.VerifyAndSetOIOUBLSetupPath(SalesHeader."Document Type");
    //         Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
    //         SalesPostPrint.GetReport(SalesHeader);
    //     end;
    // end; 
}