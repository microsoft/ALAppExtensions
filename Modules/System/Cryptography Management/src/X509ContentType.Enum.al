// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Specifies the format of an X.509 certificate.</summary>
enum 1286 "X509 Content Type"
{
    Extensible = true;

    value(0; Unknown) { }
    value(1; Cert) { }
    value(2; PFXSerializedCert) { }
    value(3; Pkcs12) { }
    value(4; SerializedStore) { }
    value(5; Pkcs7) { }
    value(6; Authenticode) { }
}