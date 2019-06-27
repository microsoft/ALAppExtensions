// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 4101 "Persistent Blob Mgt."
{
    Access = Public;

    var
        PersistentBlobMgtImpl: Codeunit "Persistent Blob Mgt. Impl.";

        /// <summary>
        /// Create a new empty PersistentBlob.
        /// </summary>
        /// <returns>The key of the new BLOB.</returns>
    procedure Create(): BigInteger
    begin
        exit(PersistentBlobMgtImpl.Create());
    end;

    /// <summary>
    /// Check whether a BLOB with the Key exists.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <returns>True if the BLOB with the given key exists.</returns>
    procedure Exists("Key": BigInteger): Boolean
    begin
        exit(PersistentBlobMgtImpl.Exists(Key));
    end;

    /// <summary>
    /// Delete the BLOB with the Key.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <returns>True if the BLOB with the given key was deleted.</returns>
    procedure Delete("Key": BigInteger): Boolean
    begin
        exit(PersistentBlobMgtImpl.Delete(Key));
    end;

    /// <summary>
    /// Save the content of the stream to the PersistentBlob.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <param name="Source">The InStream from which content will be copied to the PersistentBlob.</param>
    /// <returns>True if the BLOB with the given key was updated with the contents of the source.</returns>
    procedure CopyFromInStream("Key": BigInteger; Source: InStream): Boolean
    begin
        exit(PersistentBlobMgtImpl.CopyFromInStream(Key, Source));
    end;

    /// <summary>
    /// Write the content of the PersistentBlob to the Destination OutStream.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <param name="Destination">The OutStream to which the contents of the PersistentBlob will be copied.</param>
    /// <returns>True if the BLOB with the given Key was copied to the Destination.</returns>
    procedure CopyToOutStream("Key": BigInteger; Destination: OutStream): Boolean
    begin
        exit(PersistentBlobMgtImpl.CopyToOutStream(Key, Destination));
    end;
}

