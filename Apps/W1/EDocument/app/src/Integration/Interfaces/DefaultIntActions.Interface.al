// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;

#if not CLEAN26
interface "Default Int. Actions" extends "E-Document Integration"
#else
interface "Default Int. Actions"
#endif
{

    procedure SentDocumentApproval(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean;

    procedure SentDocumentCancellation(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean;

    procedure OpenServiceIntegrationSetupPage(var EDocumentService: Record "E-Document Service"): Boolean

}