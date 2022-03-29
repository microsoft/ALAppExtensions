// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The interface for storing BLOB data between sessions.
/// </summary>
codeunit 4101 "Persistent Blob"
{
    Access = Public;

    var
        PersistentBlobImpl: Codeunit "Persistent Blob Impl.";

    /// <summary>
    /// Create a new empty PersistentBlob.
    /// </summary>
    /// <returns>The key of the new BLOB.</returns>
    procedure Create(): BigInteger
    begin
        exit(PersistentBlobImpl.Create());
    end;

    /// <summary>
    /// Check whether a BLOB with the Key exists.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <returns>True if the BLOB with the given key exists.</returns>
    procedure Exists("Key": BigInteger): Boolean
    begin
        exit(PersistentBlobImpl.Exists(Key));
    end;

    /// <summary>
    /// Delete the BLOB with the Key.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <returns>True if the BLOB with the given key was deleted.</returns>
    procedure Delete("Key": BigInteger): Boolean
    begin
        exit(PersistentBlobImpl.Delete(Key));
    end;

    /// <summary>
    /// Save the content of the stream to the PersistentBlob.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <param name="SourceInStream">The InStream from which content will be copied to the PersistentBlob.</param>
    /// <returns>True if the BLOB with the given key was updated with the contents of the source.</returns>
    procedure CopyFromInStream("Key": BigInteger; SourceInStream: InStream): Boolean
    begin
        exit(PersistentBlobImpl.CopyFromInStream(Key, SourceInStream));
    end;

    /// <summary>
    /// Write the content of the PersistentBlob to the Destination OutStream.
    /// </summary>
    /// <param name="Key">The key of the BLOB.</param>
    /// <param name="DestinationOutStream">The OutStream to which the contents of the PersistentBlob will be copied.</param>
    /// <returns>True if the BLOB with the given Key was copied to the Destination.</returns>
    procedure CopyToOutStream("Key": BigInteger; DestinationOutStream: OutStream): Boolean
    begin
        exit(PersistentBlobImpl.CopyToOutStream(Key, DestinationOutStream));
    end;
}

