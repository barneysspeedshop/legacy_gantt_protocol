// This is a generated file - do not edit.
//
// Generated from gantt_protocol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use protocolTaskDescriptor instead')
const ProtocolTask$json = {
  '1': 'ProtocolTask',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'rowId', '3': 2, '4': 1, '5': 9, '10': 'rowId'},
    {'1': 'start', '3': 3, '4': 1, '5': 9, '10': 'start'},
    {'1': 'end', '3': 4, '4': 1, '5': 9, '10': 'end'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'completion', '3': 6, '4': 1, '5': 1, '10': 'completion'},
    {'1': 'isSummary', '3': 7, '4': 1, '5': 8, '10': 'isSummary'},
    {'1': 'isMilestone', '3': 8, '4': 1, '5': 8, '10': 'isMilestone'},
    {'1': 'resourceId', '3': 9, '4': 1, '5': 9, '10': 'resourceId'},
    {'1': 'parentId', '3': 10, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'notes', '3': 11, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'isDeleted', '3': 12, '4': 1, '5': 8, '10': 'isDeleted'},
    {'1': 'lastUpdated', '3': 13, '4': 1, '5': 9, '10': 'lastUpdated'},
    {'1': 'lastUpdatedBy', '3': 14, '4': 1, '5': 9, '10': 'lastUpdatedBy'},
    {
      '1': 'fieldTimestamps',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.ProtocolTask.FieldTimestampsEntry',
      '10': 'fieldTimestamps'
    },
    {'1': 'metadataJson', '3': 16, '4': 1, '5': 9, '10': 'metadataJson'},
  ],
  '3': [ProtocolTask_FieldTimestampsEntry$json],
};

@$core.Deprecated('Use protocolTaskDescriptor instead')
const ProtocolTask_FieldTimestampsEntry$json = {
  '1': 'FieldTimestampsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ProtocolTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List protocolTaskDescriptor = $convert.base64Decode(
    'CgxQcm90b2NvbFRhc2sSDgoCaWQYASABKAlSAmlkEhQKBXJvd0lkGAIgASgJUgVyb3dJZBIUCg'
    'VzdGFydBgDIAEoCVIFc3RhcnQSEAoDZW5kGAQgASgJUgNlbmQSEgoEbmFtZRgFIAEoCVIEbmFt'
    'ZRIeCgpjb21wbGV0aW9uGAYgASgBUgpjb21wbGV0aW9uEhwKCWlzU3VtbWFyeRgHIAEoCFIJaX'
    'NTdW1tYXJ5EiAKC2lzTWlsZXN0b25lGAggASgIUgtpc01pbGVzdG9uZRIeCgpyZXNvdXJjZUlk'
    'GAkgASgJUgpyZXNvdXJjZUlkEhoKCHBhcmVudElkGAogASgJUghwYXJlbnRJZBIUCgVub3Rlcx'
    'gLIAEoCVIFbm90ZXMSHAoJaXNEZWxldGVkGAwgASgIUglpc0RlbGV0ZWQSIAoLbGFzdFVwZGF0'
    'ZWQYDSABKAlSC2xhc3RVcGRhdGVkEiQKDWxhc3RVcGRhdGVkQnkYDiABKAlSDWxhc3RVcGRhdG'
    'VkQnkSWwoPZmllbGRUaW1lc3RhbXBzGA8gAygLMjEuZ2FudHRfcHJvdG9jb2wuUHJvdG9jb2xU'
    'YXNrLkZpZWxkVGltZXN0YW1wc0VudHJ5Ug9maWVsZFRpbWVzdGFtcHMSIgoMbWV0YWRhdGFKc2'
    '9uGBAgASgJUgxtZXRhZGF0YUpzb24aQgoURmllbGRUaW1lc3RhbXBzRW50cnkSEAoDa2V5GAEg'
    'ASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use protocolDependencyDescriptor instead')
const ProtocolDependency$json = {
  '1': 'ProtocolDependency',
  '2': [
    {
      '1': 'predecessorTaskId',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'predecessorTaskId'
    },
    {'1': 'successorTaskId', '3': 2, '4': 1, '5': 9, '10': 'successorTaskId'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'lag', '3': 4, '4': 1, '5': 3, '10': 'lag'},
    {'1': 'lastUpdated', '3': 5, '4': 1, '5': 9, '10': 'lastUpdated'},
  ],
};

/// Descriptor for `ProtocolDependency`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List protocolDependencyDescriptor = $convert.base64Decode(
    'ChJQcm90b2NvbERlcGVuZGVuY3kSLAoRcHJlZGVjZXNzb3JUYXNrSWQYASABKAlSEXByZWRlY2'
    'Vzc29yVGFza0lkEigKD3N1Y2Nlc3NvclRhc2tJZBgCIAEoCVIPc3VjY2Vzc29yVGFza0lkEhIK'
    'BHR5cGUYAyABKAlSBHR5cGUSEAoDbGFnGAQgASgDUgNsYWcSIAoLbGFzdFVwZGF0ZWQYBSABKA'
    'lSC2xhc3RVcGRhdGVk');

@$core.Deprecated('Use protocolResourceDescriptor instead')
const ProtocolResource$json = {
  '1': 'ProtocolResource',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'parentId', '3': 3, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'isDeleted', '3': 5, '4': 1, '5': 8, '10': 'isDeleted'},
    {'1': 'metadataJson', '3': 6, '4': 1, '5': 9, '10': 'metadataJson'},
    {'1': 'lastUpdated', '3': 7, '4': 1, '5': 9, '10': 'lastUpdated'},
  ],
};

/// Descriptor for `ProtocolResource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List protocolResourceDescriptor = $convert.base64Decode(
    'ChBQcm90b2NvbFJlc291cmNlEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
    'oKCHBhcmVudElkGAMgASgJUghwYXJlbnRJZBISCgR0eXBlGAQgASgJUgR0eXBlEhwKCWlzRGVs'
    'ZXRlZBgFIAEoCFIJaXNEZWxldGVkEiIKDG1ldGFkYXRhSnNvbhgGIAEoCVIMbWV0YWRhdGFKc2'
    '9uEiAKC2xhc3RVcGRhdGVkGAcgASgJUgtsYXN0VXBkYXRlZA==');

@$core.Deprecated('Use merkleNodeDescriptor instead')
const MerkleNode$json = {
  '1': 'MerkleNode',
  '2': [
    {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {
      '1': 'children',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.MerkleNode.ChildrenEntry',
      '10': 'children'
    },
  ],
  '3': [MerkleNode_ChildrenEntry$json],
};

@$core.Deprecated('Use merkleNodeDescriptor instead')
const MerkleNode_ChildrenEntry$json = {
  '1': 'ChildrenEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.MerkleNode',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `MerkleNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List merkleNodeDescriptor = $convert.base64Decode(
    'CgpNZXJrbGVOb2RlEhYKBnByZWZpeBgBIAEoCVIGcHJlZml4EhIKBGhhc2gYAiABKAlSBGhhc2'
    'gSRAoIY2hpbGRyZW4YAyADKAsyKC5nYW50dF9wcm90b2NvbC5NZXJrbGVOb2RlLkNoaWxkcmVu'
    'RW50cnlSCGNoaWxkcmVuGlcKDUNoaWxkcmVuRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSMAoFdm'
    'FsdWUYAiABKAsyGi5nYW50dF9wcm90b2NvbC5NZXJrbGVOb2RlUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = {
  '1': 'SubscribeRequest',
  '2': [
    {'1': 'channel', '3': 1, '4': 1, '5': 9, '10': 'channel'},
    {
      '1': 'last_synced_timestamp',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'lastSyncedTimestamp'
    },
  ],
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSZXF1ZXN0EhgKB2NoYW5uZWwYASABKAlSB2NoYW5uZWwSMgoVbGFzdF9zeW'
    '5jZWRfdGltZXN0YW1wGAIgASgJUhNsYXN0U3luY2VkVGltZXN0YW1w');

@$core.Deprecated('Use batchUpdatePayloadDescriptor instead')
const BatchUpdatePayload$json = {
  '1': 'BatchUpdatePayload',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.ProtocolTask',
      '10': 'tasks'
    },
    {
      '1': 'dependencies',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.ProtocolDependency',
      '10': 'dependencies'
    },
    {
      '1': 'resources',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.ProtocolResource',
      '10': 'resources'
    },
  ],
};

/// Descriptor for `BatchUpdatePayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchUpdatePayloadDescriptor = $convert.base64Decode(
    'ChJCYXRjaFVwZGF0ZVBheWxvYWQSMgoFdGFza3MYASADKAsyHC5nYW50dF9wcm90b2NvbC5Qcm'
    '90b2NvbFRhc2tSBXRhc2tzEkYKDGRlcGVuZGVuY2llcxgCIAMoCzIiLmdhbnR0X3Byb3RvY29s'
    'LlByb3RvY29sRGVwZW5kZW5jeVIMZGVwZW5kZW5jaWVzEj4KCXJlc291cmNlcxgDIAMoCzIgLm'
    'dhbnR0X3Byb3RvY29sLlByb3RvY29sUmVzb3VyY2VSCXJlc291cmNlcw==');

@$core.Deprecated('Use syncMetadataPayloadDescriptor instead')
const SyncMetadataPayload$json = {
  '1': 'SyncMetadataPayload',
  '2': [
    {'1': 'total_operations', '3': 1, '4': 1, '5': 3, '10': 'totalOperations'},
  ],
};

/// Descriptor for `SyncMetadataPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncMetadataPayloadDescriptor = $convert.base64Decode(
    'ChNTeW5jTWV0YWRhdGFQYXlsb2FkEikKEHRvdGFsX29wZXJhdGlvbnMYASABKANSD3RvdGFsT3'
    'BlcmF0aW9ucw==');

@$core.Deprecated('Use merkleRootPayloadDescriptor instead')
const MerkleRootPayload$json = {
  '1': 'MerkleRootPayload',
  '2': [
    {'1': 'root', '3': 1, '4': 1, '5': 9, '10': 'root'},
  ],
};

/// Descriptor for `MerkleRootPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List merkleRootPayloadDescriptor = $convert
    .base64Decode('ChFNZXJrbGVSb290UGF5bG9hZBISCgRyb290GAEgASgJUgRyb290');

@$core.Deprecated('Use merkleNodePayloadDescriptor instead')
const MerkleNodePayload$json = {
  '1': 'MerkleNodePayload',
  '2': [
    {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
    {
      '1': 'children',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.MerkleNodePayload.ChildrenEntry',
      '10': 'children'
    },
  ],
  '3': [MerkleNodePayload_ChildrenEntry$json],
};

@$core.Deprecated('Use merkleNodePayloadDescriptor instead')
const MerkleNodePayload_ChildrenEntry$json = {
  '1': 'ChildrenEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MerkleNodePayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List merkleNodePayloadDescriptor = $convert.base64Decode(
    'ChFNZXJrbGVOb2RlUGF5bG9hZBIWCgZwcmVmaXgYASABKAlSBnByZWZpeBJLCghjaGlsZHJlbh'
    'gCIAMoCzIvLmdhbnR0X3Byb3RvY29sLk1lcmtsZU5vZGVQYXlsb2FkLkNoaWxkcmVuRW50cnlS'
    'CGNoaWxkcmVuGjsKDUNoaWxkcmVuRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAi'
    'ABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use singleOperationPayloadDescriptor instead')
const SingleOperationPayload$json = {
  '1': 'SingleOperationPayload',
  '2': [
    {'1': 'operation_type', '3': 1, '4': 1, '5': 9, '10': 'operationType'},
    {
      '1': 'task',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.ProtocolTask',
      '10': 'task'
    },
    {
      '1': 'dependency',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.ProtocolDependency',
      '10': 'dependency'
    },
    {
      '1': 'resource',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.ProtocolResource',
      '10': 'resource'
    },
    {'1': 'metadataJson', '3': 5, '4': 1, '5': 9, '10': 'metadataJson'},
  ],
};

/// Descriptor for `SingleOperationPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List singleOperationPayloadDescriptor = $convert.base64Decode(
    'ChZTaW5nbGVPcGVyYXRpb25QYXlsb2FkEiUKDm9wZXJhdGlvbl90eXBlGAEgASgJUg1vcGVyYX'
    'Rpb25UeXBlEjAKBHRhc2sYAiABKAsyHC5nYW50dF9wcm90b2NvbC5Qcm90b2NvbFRhc2tSBHRh'
    'c2sSQgoKZGVwZW5kZW5jeRgDIAEoCzIiLmdhbnR0X3Byb3RvY29sLlByb3RvY29sRGVwZW5kZW'
    '5jeVIKZGVwZW5kZW5jeRI8CghyZXNvdXJjZRgEIAEoCzIgLmdhbnR0X3Byb3RvY29sLlByb3Rv'
    'Y29sUmVzb3VyY2VSCHJlc291cmNlEiIKDG1ldGFkYXRhSnNvbhgFIAEoCVIMbWV0YWRhdGFKc2'
    '9u');

@$core.Deprecated('Use getMerkleNodeRequestDescriptor instead')
const GetMerkleNodeRequest$json = {
  '1': 'GetMerkleNodeRequest',
  '2': [
    {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
  ],
};

/// Descriptor for `GetMerkleNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMerkleNodeRequestDescriptor =
    $convert.base64Decode(
        'ChRHZXRNZXJrbGVOb2RlUmVxdWVzdBIWCgZwcmVmaXgYASABKAlSBnByZWZpeA==');

@$core.Deprecated('Use getEntitiesInRangeRequestDescriptor instead')
const GetEntitiesInRangeRequest$json = {
  '1': 'GetEntitiesInRangeRequest',
  '2': [
    {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
  ],
};

/// Descriptor for `GetEntitiesInRangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEntitiesInRangeRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRFbnRpdGllc0luUmFuZ2VSZXF1ZXN0EhYKBnByZWZpeBgBIAEoCVIGcHJlZml4');

@$core.Deprecated('Use protocolMessageDescriptor instead')
const ProtocolMessage$json = {
  '1': 'ProtocolMessage',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'channel', '3': 2, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 9, '10': 'timestamp'},
    {'1': 'actor_id', '3': 4, '4': 1, '5': 9, '10': 'actorId'},
    {'1': 'error', '3': 5, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'subscribe',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.SubscribeRequest',
      '9': 0,
      '10': 'subscribe'
    },
    {
      '1': 'batch_update',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.BatchUpdatePayload',
      '9': 0,
      '10': 'batchUpdate'
    },
    {
      '1': 'sync_metadata',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.SyncMetadataPayload',
      '9': 0,
      '10': 'syncMetadata'
    },
    {
      '1': 'merkle_root',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.MerkleRootPayload',
      '9': 0,
      '10': 'merkleRoot'
    },
    {
      '1': 'merkle_node',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.MerkleNodePayload',
      '9': 0,
      '10': 'merkleNode'
    },
    {
      '1': 'single_operation',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.SingleOperationPayload',
      '9': 0,
      '10': 'singleOperation'
    },
    {
      '1': 'get_merkle_node',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.GetMerkleNodeRequest',
      '9': 0,
      '10': 'getMerkleNode'
    },
    {
      '1': 'get_entities_in_range',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.GetEntitiesInRangeRequest',
      '9': 0,
      '10': 'getEntitiesInRange'
    },
    {
      '1': 'solver_request',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.SolverRequest',
      '9': 0,
      '10': 'solverRequest'
    },
    {
      '1': 'solver_response',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.gantt_protocol.SolverResponse',
      '9': 0,
      '10': 'solverResponse'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `ProtocolMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List protocolMessageDescriptor = $convert.base64Decode(
    'Cg9Qcm90b2NvbE1lc3NhZ2USEgoEdHlwZRgBIAEoCVIEdHlwZRIYCgdjaGFubmVsGAIgASgJUg'
    'djaGFubmVsEhwKCXRpbWVzdGFtcBgDIAEoCVIJdGltZXN0YW1wEhkKCGFjdG9yX2lkGAQgASgJ'
    'UgdhY3RvcklkEhQKBWVycm9yGAUgASgJUgVlcnJvchJACglzdWJzY3JpYmUYCiABKAsyIC5nYW'
    '50dF9wcm90b2NvbC5TdWJzY3JpYmVSZXF1ZXN0SABSCXN1YnNjcmliZRJHCgxiYXRjaF91cGRh'
    'dGUYCyABKAsyIi5nYW50dF9wcm90b2NvbC5CYXRjaFVwZGF0ZVBheWxvYWRIAFILYmF0Y2hVcG'
    'RhdGUSSgoNc3luY19tZXRhZGF0YRgMIAEoCzIjLmdhbnR0X3Byb3RvY29sLlN5bmNNZXRhZGF0'
    'YVBheWxvYWRIAFIMc3luY01ldGFkYXRhEkQKC21lcmtsZV9yb290GA0gASgLMiEuZ2FudHRfcH'
    'JvdG9jb2wuTWVya2xlUm9vdFBheWxvYWRIAFIKbWVya2xlUm9vdBJECgttZXJrbGVfbm9kZRgO'
    'IAEoCzIhLmdhbnR0X3Byb3RvY29sLk1lcmtsZU5vZGVQYXlsb2FkSABSCm1lcmtsZU5vZGUSUw'
    'oQc2luZ2xlX29wZXJhdGlvbhgPIAEoCzImLmdhbnR0X3Byb3RvY29sLlNpbmdsZU9wZXJhdGlv'
    'blBheWxvYWRIAFIPc2luZ2xlT3BlcmF0aW9uEk4KD2dldF9tZXJrbGVfbm9kZRgQIAEoCzIkLm'
    'dhbnR0X3Byb3RvY29sLkdldE1lcmtsZU5vZGVSZXF1ZXN0SABSDWdldE1lcmtsZU5vZGUSXgoV'
    'Z2V0X2VudGl0aWVzX2luX3JhbmdlGBEgASgLMikuZ2FudHRfcHJvdG9jb2wuR2V0RW50aXRpZX'
    'NJblJhbmdlUmVxdWVzdEgAUhJnZXRFbnRpdGllc0luUmFuZ2USRgoOc29sdmVyX3JlcXVlc3QY'
    'FCABKAsyHS5nYW50dF9wcm90b2NvbC5Tb2x2ZXJSZXF1ZXN0SABSDXNvbHZlclJlcXVlc3QSSQ'
    'oPc29sdmVyX3Jlc3BvbnNlGBUgASgLMh4uZ2FudHRfcHJvdG9jb2wuU29sdmVyUmVzcG9uc2VI'
    'AFIOc29sdmVyUmVzcG9uc2VCCQoHcGF5bG9hZA==');

@$core.Deprecated('Use solverRequestDescriptor instead')
const SolverRequest$json = {
  '1': 'SolverRequest',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.ProtocolTask',
      '10': 'tasks'
    },
    {
      '1': 'dependencies',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.ProtocolDependency',
      '10': 'dependencies'
    },
    {'1': 'algorithmLevel', '3': 3, '4': 1, '5': 5, '10': 'algorithmLevel'},
  ],
};

/// Descriptor for `SolverRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List solverRequestDescriptor = $convert.base64Decode(
    'Cg1Tb2x2ZXJSZXF1ZXN0EjIKBXRhc2tzGAEgAygLMhwuZ2FudHRfcHJvdG9jb2wuUHJvdG9jb2'
    'xUYXNrUgV0YXNrcxJGCgxkZXBlbmRlbmNpZXMYAiADKAsyIi5nYW50dF9wcm90b2NvbC5Qcm90'
    'b2NvbERlcGVuZGVuY3lSDGRlcGVuZGVuY2llcxImCg5hbGdvcml0aG1MZXZlbBgDIAEoBVIOYW'
    'xnb3JpdGhtTGV2ZWw=');

@$core.Deprecated('Use solverResponseDescriptor instead')
const SolverResponse$json = {
  '1': 'SolverResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'errorMessage', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'tasks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gantt_protocol.ProtocolTask',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `SolverResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List solverResponseDescriptor = $convert.base64Decode(
    'Cg5Tb2x2ZXJSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiIKDGVycm9yTWVzc2'
    'FnZRgCIAEoCVIMZXJyb3JNZXNzYWdlEjIKBXRhc2tzGAMgAygLMhwuZ2FudHRfcHJvdG9jb2wu'
    'UHJvdG9jb2xUYXNrUgV0YXNrcw==');
