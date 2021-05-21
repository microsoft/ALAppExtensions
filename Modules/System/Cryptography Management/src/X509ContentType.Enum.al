// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Specifies the format of an X.509 certificate.</summary>
enum 1286 "X509 Content Type"
{
    Extensible = false;

    /// <summary>
    /// Specifies unknown X.509 certificate.
    /// </summary>
    value(0; Unknown) { }

    /// <summary>
    /// Specifies a single X.509 certificate.
    /// </summary>
    value(1; Cert) { }

    /// <summary>
    /// Specifies a single serialized X.509 certificate.
    /// </summary>
    value(2; PFXSerializedCert) { }

    /// <summary>
    /// Specifies a PKCS #12-formatted certificate. The Pkcs12 value is identical to the Pfx value.
    /// </summary>
    value(3; Pkcs12) { }

    /// <summary>
    /// Specifies a serialized store.
    /// </summary>
    value(4; SerializedStore) { }

    /// <summary>
    /// Specifies a PKCS #7-formatted certificate.
    /// </summary>
    value(5; Pkcs7) { }

    /// <summary>
    /// Specifies an Authenticode X.509 certificate.
    /// </summary>
    value(6; Authenticode) { }
}