// This is a generated file - do not edit.
//
// Generated from gantt_protocol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ProtocolTask extends $pb.GeneratedMessage {
  factory ProtocolTask({
    $core.String? id,
    $core.String? rowId,
    $core.String? start,
    $core.String? end,
    $core.String? name,
    $core.double? completion,
    $core.bool? isSummary,
    $core.bool? isMilestone,
    $core.String? resourceId,
    $core.String? parentId,
    $core.String? notes,
    $core.bool? isDeleted,
    $core.String? lastUpdated,
    $core.String? lastUpdatedBy,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? fieldTimestamps,
    $core.String? metadataJson,
  }) {
    final result = ProtocolTask._();
    if (id != null) result.id = id;
    if (rowId != null) result.rowId = rowId;
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    if (name != null) result.name = name;
    if (completion != null) result.completion = completion;
    if (isSummary != null) result.isSummary = isSummary;
    if (isMilestone != null) result.isMilestone = isMilestone;
    if (resourceId != null) result.resourceId = resourceId;
    if (parentId != null) result.parentId = parentId;
    if (notes != null) result.notes = notes;
    if (isDeleted != null) result.isDeleted = isDeleted;
    if (lastUpdated != null) result.lastUpdated = lastUpdated;
    if (lastUpdatedBy != null) result.lastUpdatedBy = lastUpdatedBy;
    if (fieldTimestamps != null)
      result.fieldTimestamps.addEntries(fieldTimestamps);
    if (metadataJson != null) result.metadataJson = metadataJson;
    return result;
  }

  ProtocolTask._();

  factory ProtocolTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolTask()..mergeFromBuffer(data, registry);
  factory ProtocolTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProtocolTask',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: ProtocolTask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'rowId', protoName: 'rowId')
    ..aOS(3, _omitFieldNames ? '' : 'start')
    ..aOS(4, _omitFieldNames ? '' : 'end')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aD(6, _omitFieldNames ? '' : 'completion')
    ..aOB(7, _omitFieldNames ? '' : 'isSummary', protoName: 'isSummary')
    ..aOB(8, _omitFieldNames ? '' : 'isMilestone', protoName: 'isMilestone')
    ..aOS(9, _omitFieldNames ? '' : 'resourceId', protoName: 'resourceId')
    ..aOS(10, _omitFieldNames ? '' : 'parentId', protoName: 'parentId')
    ..aOS(11, _omitFieldNames ? '' : 'notes')
    ..aOB(12, _omitFieldNames ? '' : 'isDeleted', protoName: 'isDeleted')
    ..aOS(13, _omitFieldNames ? '' : 'lastUpdated', protoName: 'lastUpdated')
    ..aOS(14, _omitFieldNames ? '' : 'lastUpdatedBy',
        protoName: 'lastUpdatedBy')
    ..m<$core.String, $core.String>(
        15, _omitFieldNames ? '' : 'fieldTimestamps',
        protoName: 'fieldTimestamps',
        entryClassName: 'ProtocolTask.FieldTimestampsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gantt_protocol'))
    ..aOS(16, _omitFieldNames ? '' : 'metadataJson', protoName: 'metadataJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolTask copyWith(void Function(ProtocolTask) updates) =>
      super.copyWith((message) => updates(message as ProtocolTask))
          as ProtocolTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProtocolTask() / ProtocolTask.new instead')
  static ProtocolTask create() => ProtocolTask._();
  static $pb.GeneratedMessage $_createMessage() => ProtocolTask._();
  @$core.override
  ProtocolTask createEmptyInstance() => ProtocolTask._();
  @$core.pragma('dart2js:noInline')
  static ProtocolTask getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProtocolTask>(
          ProtocolTask.$_createMessage);
  static ProtocolTask? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rowId => $_getSZ(1);
  @$pb.TagNumber(2)
  set rowId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRowId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRowId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get start => $_getSZ(2);
  @$pb.TagNumber(3)
  set start($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearStart() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get end => $_getSZ(3);
  @$pb.TagNumber(4)
  set end($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnd() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get completion => $_getN(5);
  @$pb.TagNumber(6)
  set completion($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCompletion() => $_has(5);
  @$pb.TagNumber(6)
  void clearCompletion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isSummary => $_getBF(6);
  @$pb.TagNumber(7)
  set isSummary($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsSummary() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsSummary() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isMilestone => $_getBF(7);
  @$pb.TagNumber(8)
  set isMilestone($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsMilestone() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsMilestone() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get resourceId => $_getSZ(8);
  @$pb.TagNumber(9)
  set resourceId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasResourceId() => $_has(8);
  @$pb.TagNumber(9)
  void clearResourceId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get parentId => $_getSZ(9);
  @$pb.TagNumber(10)
  set parentId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasParentId() => $_has(9);
  @$pb.TagNumber(10)
  void clearParentId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get notes => $_getSZ(10);
  @$pb.TagNumber(11)
  set notes($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasNotes() => $_has(10);
  @$pb.TagNumber(11)
  void clearNotes() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get isDeleted => $_getBF(11);
  @$pb.TagNumber(12)
  set isDeleted($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasIsDeleted() => $_has(11);
  @$pb.TagNumber(12)
  void clearIsDeleted() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get lastUpdated => $_getSZ(12);
  @$pb.TagNumber(13)
  set lastUpdated($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasLastUpdated() => $_has(12);
  @$pb.TagNumber(13)
  void clearLastUpdated() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get lastUpdatedBy => $_getSZ(13);
  @$pb.TagNumber(14)
  set lastUpdatedBy($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasLastUpdatedBy() => $_has(13);
  @$pb.TagNumber(14)
  void clearLastUpdatedBy() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbMap<$core.String, $core.String> get fieldTimestamps => $_getMap(14);

  @$pb.TagNumber(16)
  $core.String get metadataJson => $_getSZ(15);
  @$pb.TagNumber(16)
  set metadataJson($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasMetadataJson() => $_has(15);
  @$pb.TagNumber(16)
  void clearMetadataJson() => $_clearField(16);
}

class ProtocolDependency extends $pb.GeneratedMessage {
  factory ProtocolDependency({
    $core.String? predecessorTaskId,
    $core.String? successorTaskId,
    $core.String? type,
    $fixnum.Int64? lag,
    $core.String? lastUpdated,
  }) {
    final result = ProtocolDependency._();
    if (predecessorTaskId != null) result.predecessorTaskId = predecessorTaskId;
    if (successorTaskId != null) result.successorTaskId = successorTaskId;
    if (type != null) result.type = type;
    if (lag != null) result.lag = lag;
    if (lastUpdated != null) result.lastUpdated = lastUpdated;
    return result;
  }

  ProtocolDependency._();

  factory ProtocolDependency.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolDependency()..mergeFromBuffer(data, registry);
  factory ProtocolDependency.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolDependency()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProtocolDependency',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: ProtocolDependency.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'predecessorTaskId',
        protoName: 'predecessorTaskId')
    ..aOS(2, _omitFieldNames ? '' : 'successorTaskId',
        protoName: 'successorTaskId')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aInt64(4, _omitFieldNames ? '' : 'lag')
    ..aOS(5, _omitFieldNames ? '' : 'lastUpdated', protoName: 'lastUpdated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolDependency clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolDependency copyWith(void Function(ProtocolDependency) updates) =>
      super.copyWith((message) => updates(message as ProtocolDependency))
          as ProtocolDependency;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProtocolDependency() / ProtocolDependency.new instead')
  static ProtocolDependency create() => ProtocolDependency._();
  static $pb.GeneratedMessage $_createMessage() => ProtocolDependency._();
  @$core.override
  ProtocolDependency createEmptyInstance() => ProtocolDependency._();
  @$core.pragma('dart2js:noInline')
  static ProtocolDependency getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProtocolDependency>(
          ProtocolDependency.$_createMessage);
  static ProtocolDependency? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get predecessorTaskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set predecessorTaskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPredecessorTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPredecessorTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get successorTaskId => $_getSZ(1);
  @$pb.TagNumber(2)
  set successorTaskId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccessorTaskId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccessorTaskId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get lag => $_getI64(3);
  @$pb.TagNumber(4)
  set lag($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLag() => $_has(3);
  @$pb.TagNumber(4)
  void clearLag() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get lastUpdated => $_getSZ(4);
  @$pb.TagNumber(5)
  set lastUpdated($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLastUpdated() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastUpdated() => $_clearField(5);
}

class ProtocolResource extends $pb.GeneratedMessage {
  factory ProtocolResource({
    $core.String? id,
    $core.String? name,
    $core.String? parentId,
    $core.String? type,
    $core.bool? isDeleted,
    $core.String? metadataJson,
    $core.String? lastUpdated,
  }) {
    final result = ProtocolResource._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (parentId != null) result.parentId = parentId;
    if (type != null) result.type = type;
    if (isDeleted != null) result.isDeleted = isDeleted;
    if (metadataJson != null) result.metadataJson = metadataJson;
    if (lastUpdated != null) result.lastUpdated = lastUpdated;
    return result;
  }

  ProtocolResource._();

  factory ProtocolResource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolResource()..mergeFromBuffer(data, registry);
  factory ProtocolResource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolResource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProtocolResource',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: ProtocolResource.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'parentId', protoName: 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..aOB(5, _omitFieldNames ? '' : 'isDeleted', protoName: 'isDeleted')
    ..aOS(6, _omitFieldNames ? '' : 'metadataJson', protoName: 'metadataJson')
    ..aOS(7, _omitFieldNames ? '' : 'lastUpdated', protoName: 'lastUpdated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolResource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolResource copyWith(void Function(ProtocolResource) updates) =>
      super.copyWith((message) => updates(message as ProtocolResource))
          as ProtocolResource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProtocolResource() / ProtocolResource.new instead')
  static ProtocolResource create() => ProtocolResource._();
  static $pb.GeneratedMessage $_createMessage() => ProtocolResource._();
  @$core.override
  ProtocolResource createEmptyInstance() => ProtocolResource._();
  @$core.pragma('dart2js:noInline')
  static ProtocolResource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProtocolResource>(
          ProtocolResource.$_createMessage);
  static ProtocolResource? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isDeleted => $_getBF(4);
  @$pb.TagNumber(5)
  set isDeleted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsDeleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsDeleted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get metadataJson => $_getSZ(5);
  @$pb.TagNumber(6)
  set metadataJson($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMetadataJson() => $_has(5);
  @$pb.TagNumber(6)
  void clearMetadataJson() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get lastUpdated => $_getSZ(6);
  @$pb.TagNumber(7)
  set lastUpdated($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLastUpdated() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastUpdated() => $_clearField(7);
}

class MerkleNode extends $pb.GeneratedMessage {
  factory MerkleNode({
    $core.String? prefix,
    $core.String? hash,
    $core.Iterable<$core.MapEntry<$core.String, MerkleNode>>? children,
  }) {
    final result = MerkleNode._();
    if (prefix != null) result.prefix = prefix;
    if (hash != null) result.hash = hash;
    if (children != null) result.children.addEntries(children);
    return result;
  }

  MerkleNode._();

  factory MerkleNode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleNode()..mergeFromBuffer(data, registry);
  factory MerkleNode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleNode()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MerkleNode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: MerkleNode.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'prefix')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..m<$core.String, MerkleNode>(3, _omitFieldNames ? '' : 'children',
        entryClassName: 'MerkleNode.ChildrenEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: MerkleNode.$_createMessage,
        valueDefaultOrMaker: MerkleNode.getDefault,
        packageName: const $pb.PackageName('gantt_protocol'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleNode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleNode copyWith(void Function(MerkleNode) updates) =>
      super.copyWith((message) => updates(message as MerkleNode)) as MerkleNode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MerkleNode() / MerkleNode.new instead')
  static MerkleNode create() => MerkleNode._();
  static $pb.GeneratedMessage $_createMessage() => MerkleNode._();
  @$core.override
  MerkleNode createEmptyInstance() => MerkleNode._();
  @$core.pragma('dart2js:noInline')
  static MerkleNode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MerkleNode>(MerkleNode.$_createMessage);
  static MerkleNode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, MerkleNode> get children => $_getMap(2);
}

class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest({
    $core.String? channel,
    $core.String? lastSyncedTimestamp,
  }) {
    final result = SubscribeRequest._();
    if (channel != null) result.channel = channel;
    if (lastSyncedTimestamp != null)
      result.lastSyncedTimestamp = lastSyncedTimestamp;
    return result;
  }

  SubscribeRequest._();

  factory SubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeRequest()..mergeFromBuffer(data, registry);
  factory SubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: SubscribeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'channel')
    ..aOS(2, _omitFieldNames ? '' : 'lastSyncedTimestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest copyWith(void Function(SubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeRequest))
          as SubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeRequest() / SubscribeRequest.new instead')
  static SubscribeRequest create() => SubscribeRequest._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeRequest._();
  @$core.override
  SubscribeRequest createEmptyInstance() => SubscribeRequest._();
  @$core.pragma('dart2js:noInline')
  static SubscribeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeRequest>(
          SubscribeRequest.$_createMessage);
  static SubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channel => $_getSZ(0);
  @$pb.TagNumber(1)
  set channel($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannel() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get lastSyncedTimestamp => $_getSZ(1);
  @$pb.TagNumber(2)
  set lastSyncedTimestamp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastSyncedTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastSyncedTimestamp() => $_clearField(2);
}

class BatchUpdatePayload extends $pb.GeneratedMessage {
  factory BatchUpdatePayload({
    $core.Iterable<ProtocolTask>? tasks,
    $core.Iterable<ProtocolDependency>? dependencies,
    $core.Iterable<ProtocolResource>? resources,
  }) {
    final result = BatchUpdatePayload._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (dependencies != null) result.dependencies.addAll(dependencies);
    if (resources != null) result.resources.addAll(resources);
    return result;
  }

  BatchUpdatePayload._();

  factory BatchUpdatePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BatchUpdatePayload()..mergeFromBuffer(data, registry);
  factory BatchUpdatePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BatchUpdatePayload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchUpdatePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: BatchUpdatePayload.$_createMessage)
    ..pPM<ProtocolTask>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: ProtocolTask.$_createMessage)
    ..pPM<ProtocolDependency>(2, _omitFieldNames ? '' : 'dependencies',
        subBuilder: ProtocolDependency.$_createMessage)
    ..pPM<ProtocolResource>(3, _omitFieldNames ? '' : 'resources',
        subBuilder: ProtocolResource.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchUpdatePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchUpdatePayload copyWith(void Function(BatchUpdatePayload) updates) =>
      super.copyWith((message) => updates(message as BatchUpdatePayload))
          as BatchUpdatePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BatchUpdatePayload() / BatchUpdatePayload.new instead')
  static BatchUpdatePayload create() => BatchUpdatePayload._();
  static $pb.GeneratedMessage $_createMessage() => BatchUpdatePayload._();
  @$core.override
  BatchUpdatePayload createEmptyInstance() => BatchUpdatePayload._();
  @$core.pragma('dart2js:noInline')
  static BatchUpdatePayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchUpdatePayload>(
          BatchUpdatePayload.$_createMessage);
  static BatchUpdatePayload? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProtocolTask> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<ProtocolDependency> get dependencies => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<ProtocolResource> get resources => $_getList(2);
}

class SyncMetadataPayload extends $pb.GeneratedMessage {
  factory SyncMetadataPayload({
    $fixnum.Int64? totalOperations,
  }) {
    final result = SyncMetadataPayload._();
    if (totalOperations != null) result.totalOperations = totalOperations;
    return result;
  }

  SyncMetadataPayload._();

  factory SyncMetadataPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncMetadataPayload()..mergeFromBuffer(data, registry);
  factory SyncMetadataPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncMetadataPayload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncMetadataPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: SyncMetadataPayload.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'totalOperations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncMetadataPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncMetadataPayload copyWith(void Function(SyncMetadataPayload) updates) =>
      super.copyWith((message) => updates(message as SyncMetadataPayload))
          as SyncMetadataPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use SyncMetadataPayload() / SyncMetadataPayload.new instead')
  static SyncMetadataPayload create() => SyncMetadataPayload._();
  static $pb.GeneratedMessage $_createMessage() => SyncMetadataPayload._();
  @$core.override
  SyncMetadataPayload createEmptyInstance() => SyncMetadataPayload._();
  @$core.pragma('dart2js:noInline')
  static SyncMetadataPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncMetadataPayload>(
          SyncMetadataPayload.$_createMessage);
  static SyncMetadataPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalOperations => $_getI64(0);
  @$pb.TagNumber(1)
  set totalOperations($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalOperations() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalOperations() => $_clearField(1);
}

class MerkleRootPayload extends $pb.GeneratedMessage {
  factory MerkleRootPayload({
    $core.String? root,
  }) {
    final result = MerkleRootPayload._();
    if (root != null) result.root = root;
    return result;
  }

  MerkleRootPayload._();

  factory MerkleRootPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleRootPayload()..mergeFromBuffer(data, registry);
  factory MerkleRootPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleRootPayload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MerkleRootPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: MerkleRootPayload.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'root')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleRootPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleRootPayload copyWith(void Function(MerkleRootPayload) updates) =>
      super.copyWith((message) => updates(message as MerkleRootPayload))
          as MerkleRootPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MerkleRootPayload() / MerkleRootPayload.new instead')
  static MerkleRootPayload create() => MerkleRootPayload._();
  static $pb.GeneratedMessage $_createMessage() => MerkleRootPayload._();
  @$core.override
  MerkleRootPayload createEmptyInstance() => MerkleRootPayload._();
  @$core.pragma('dart2js:noInline')
  static MerkleRootPayload getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MerkleRootPayload>(
          MerkleRootPayload.$_createMessage);
  static MerkleRootPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get root => $_getSZ(0);
  @$pb.TagNumber(1)
  set root($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoot() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoot() => $_clearField(1);
}

class MerkleNodePayload extends $pb.GeneratedMessage {
  factory MerkleNodePayload({
    $core.String? prefix,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? children,
  }) {
    final result = MerkleNodePayload._();
    if (prefix != null) result.prefix = prefix;
    if (children != null) result.children.addEntries(children);
    return result;
  }

  MerkleNodePayload._();

  factory MerkleNodePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleNodePayload()..mergeFromBuffer(data, registry);
  factory MerkleNodePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MerkleNodePayload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MerkleNodePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: MerkleNodePayload.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'prefix')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'children',
        entryClassName: 'MerkleNodePayload.ChildrenEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gantt_protocol'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleNodePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MerkleNodePayload copyWith(void Function(MerkleNodePayload) updates) =>
      super.copyWith((message) => updates(message as MerkleNodePayload))
          as MerkleNodePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MerkleNodePayload() / MerkleNodePayload.new instead')
  static MerkleNodePayload create() => MerkleNodePayload._();
  static $pb.GeneratedMessage $_createMessage() => MerkleNodePayload._();
  @$core.override
  MerkleNodePayload createEmptyInstance() => MerkleNodePayload._();
  @$core.pragma('dart2js:noInline')
  static MerkleNodePayload getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MerkleNodePayload>(
          MerkleNodePayload.$_createMessage);
  static MerkleNodePayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get children => $_getMap(1);
}

class SingleOperationPayload extends $pb.GeneratedMessage {
  factory SingleOperationPayload({
    $core.String? operationType,
    ProtocolTask? task,
    ProtocolDependency? dependency,
    ProtocolResource? resource,
    $core.String? metadataJson,
  }) {
    final result = SingleOperationPayload._();
    if (operationType != null) result.operationType = operationType;
    if (task != null) result.task = task;
    if (dependency != null) result.dependency = dependency;
    if (resource != null) result.resource = resource;
    if (metadataJson != null) result.metadataJson = metadataJson;
    return result;
  }

  SingleOperationPayload._();

  factory SingleOperationPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SingleOperationPayload()..mergeFromBuffer(data, registry);
  factory SingleOperationPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SingleOperationPayload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SingleOperationPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: SingleOperationPayload.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'operationType')
    ..aOM<ProtocolTask>(2, _omitFieldNames ? '' : 'task',
        subBuilder: ProtocolTask.$_createMessage)
    ..aOM<ProtocolDependency>(3, _omitFieldNames ? '' : 'dependency',
        subBuilder: ProtocolDependency.$_createMessage)
    ..aOM<ProtocolResource>(4, _omitFieldNames ? '' : 'resource',
        subBuilder: ProtocolResource.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'metadataJson', protoName: 'metadataJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SingleOperationPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SingleOperationPayload copyWith(
          void Function(SingleOperationPayload) updates) =>
      super.copyWith((message) => updates(message as SingleOperationPayload))
          as SingleOperationPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SingleOperationPayload() / SingleOperationPayload.new instead')
  static SingleOperationPayload create() => SingleOperationPayload._();
  static $pb.GeneratedMessage $_createMessage() => SingleOperationPayload._();
  @$core.override
  SingleOperationPayload createEmptyInstance() => SingleOperationPayload._();
  @$core.pragma('dart2js:noInline')
  static SingleOperationPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SingleOperationPayload>(
          SingleOperationPayload.$_createMessage);
  static SingleOperationPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get operationType => $_getSZ(0);
  @$pb.TagNumber(1)
  set operationType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOperationType() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperationType() => $_clearField(1);

  @$pb.TagNumber(2)
  ProtocolTask get task => $_getN(1);
  @$pb.TagNumber(2)
  set task(ProtocolTask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTask() => $_has(1);
  @$pb.TagNumber(2)
  void clearTask() => $_clearField(2);
  @$pb.TagNumber(2)
  ProtocolTask ensureTask() => $_ensure(1);

  @$pb.TagNumber(3)
  ProtocolDependency get dependency => $_getN(2);
  @$pb.TagNumber(3)
  set dependency(ProtocolDependency value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDependency() => $_has(2);
  @$pb.TagNumber(3)
  void clearDependency() => $_clearField(3);
  @$pb.TagNumber(3)
  ProtocolDependency ensureDependency() => $_ensure(2);

  @$pb.TagNumber(4)
  ProtocolResource get resource => $_getN(3);
  @$pb.TagNumber(4)
  set resource(ProtocolResource value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasResource() => $_has(3);
  @$pb.TagNumber(4)
  void clearResource() => $_clearField(4);
  @$pb.TagNumber(4)
  ProtocolResource ensureResource() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get metadataJson => $_getSZ(4);
  @$pb.TagNumber(5)
  set metadataJson($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMetadataJson() => $_has(4);
  @$pb.TagNumber(5)
  void clearMetadataJson() => $_clearField(5);
}

class GetMerkleNodeRequest extends $pb.GeneratedMessage {
  factory GetMerkleNodeRequest({
    $core.String? prefix,
  }) {
    final result = GetMerkleNodeRequest._();
    if (prefix != null) result.prefix = prefix;
    return result;
  }

  GetMerkleNodeRequest._();

  factory GetMerkleNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMerkleNodeRequest()..mergeFromBuffer(data, registry);
  factory GetMerkleNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMerkleNodeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMerkleNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: GetMerkleNodeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'prefix')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMerkleNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMerkleNodeRequest copyWith(void Function(GetMerkleNodeRequest) updates) =>
      super.copyWith((message) => updates(message as GetMerkleNodeRequest))
          as GetMerkleNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetMerkleNodeRequest() / GetMerkleNodeRequest.new instead')
  static GetMerkleNodeRequest create() => GetMerkleNodeRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetMerkleNodeRequest._();
  @$core.override
  GetMerkleNodeRequest createEmptyInstance() => GetMerkleNodeRequest._();
  @$core.pragma('dart2js:noInline')
  static GetMerkleNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMerkleNodeRequest>(
          GetMerkleNodeRequest.$_createMessage);
  static GetMerkleNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => $_clearField(1);
}

class GetEntitiesInRangeRequest extends $pb.GeneratedMessage {
  factory GetEntitiesInRangeRequest({
    $core.String? prefix,
  }) {
    final result = GetEntitiesInRangeRequest._();
    if (prefix != null) result.prefix = prefix;
    return result;
  }

  GetEntitiesInRangeRequest._();

  factory GetEntitiesInRangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEntitiesInRangeRequest()..mergeFromBuffer(data, registry);
  factory GetEntitiesInRangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEntitiesInRangeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetEntitiesInRangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: GetEntitiesInRangeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'prefix')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEntitiesInRangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEntitiesInRangeRequest copyWith(
          void Function(GetEntitiesInRangeRequest) updates) =>
      super.copyWith((message) => updates(message as GetEntitiesInRangeRequest))
          as GetEntitiesInRangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetEntitiesInRangeRequest() / GetEntitiesInRangeRequest.new instead')
  static GetEntitiesInRangeRequest create() => GetEntitiesInRangeRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GetEntitiesInRangeRequest._();
  @$core.override
  GetEntitiesInRangeRequest createEmptyInstance() =>
      GetEntitiesInRangeRequest._();
  @$core.pragma('dart2js:noInline')
  static GetEntitiesInRangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEntitiesInRangeRequest>(
          GetEntitiesInRangeRequest.$_createMessage);
  static GetEntitiesInRangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => $_clearField(1);
}

enum ProtocolMessage_Payload {
  subscribe,
  batchUpdate,
  syncMetadata,
  merkleRoot,
  merkleNode,
  singleOperation,
  getMerkleNode,
  getEntitiesInRange,
  solverRequest,
  solverResponse,
  notSet
}

class ProtocolMessage extends $pb.GeneratedMessage {
  factory ProtocolMessage({
    $core.String? type,
    $core.String? channel,
    $core.String? timestamp,
    $core.String? actorId,
    $core.String? error,
    SubscribeRequest? subscribe,
    BatchUpdatePayload? batchUpdate,
    SyncMetadataPayload? syncMetadata,
    MerkleRootPayload? merkleRoot,
    MerkleNodePayload? merkleNode,
    SingleOperationPayload? singleOperation,
    GetMerkleNodeRequest? getMerkleNode,
    GetEntitiesInRangeRequest? getEntitiesInRange,
    SolverRequest? solverRequest,
    SolverResponse? solverResponse,
  }) {
    final result = ProtocolMessage._();
    if (type != null) result.type = type;
    if (channel != null) result.channel = channel;
    if (timestamp != null) result.timestamp = timestamp;
    if (actorId != null) result.actorId = actorId;
    if (error != null) result.error = error;
    if (subscribe != null) result.subscribe = subscribe;
    if (batchUpdate != null) result.batchUpdate = batchUpdate;
    if (syncMetadata != null) result.syncMetadata = syncMetadata;
    if (merkleRoot != null) result.merkleRoot = merkleRoot;
    if (merkleNode != null) result.merkleNode = merkleNode;
    if (singleOperation != null) result.singleOperation = singleOperation;
    if (getMerkleNode != null) result.getMerkleNode = getMerkleNode;
    if (getEntitiesInRange != null)
      result.getEntitiesInRange = getEntitiesInRange;
    if (solverRequest != null) result.solverRequest = solverRequest;
    if (solverResponse != null) result.solverResponse = solverResponse;
    return result;
  }

  ProtocolMessage._();

  factory ProtocolMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolMessage()..mergeFromBuffer(data, registry);
  factory ProtocolMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProtocolMessage()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ProtocolMessage_Payload>
      _ProtocolMessage_PayloadByTag = {
    10: ProtocolMessage_Payload.subscribe,
    11: ProtocolMessage_Payload.batchUpdate,
    12: ProtocolMessage_Payload.syncMetadata,
    13: ProtocolMessage_Payload.merkleRoot,
    14: ProtocolMessage_Payload.merkleNode,
    15: ProtocolMessage_Payload.singleOperation,
    16: ProtocolMessage_Payload.getMerkleNode,
    17: ProtocolMessage_Payload.getEntitiesInRange,
    20: ProtocolMessage_Payload.solverRequest,
    21: ProtocolMessage_Payload.solverResponse,
    0: ProtocolMessage_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProtocolMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: ProtocolMessage.$_createMessage)
    ..oo(0, [10, 11, 12, 13, 14, 15, 16, 17, 20, 21])
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'channel')
    ..aOS(3, _omitFieldNames ? '' : 'timestamp')
    ..aOS(4, _omitFieldNames ? '' : 'actorId')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..aOM<SubscribeRequest>(10, _omitFieldNames ? '' : 'subscribe',
        subBuilder: SubscribeRequest.$_createMessage)
    ..aOM<BatchUpdatePayload>(11, _omitFieldNames ? '' : 'batchUpdate',
        subBuilder: BatchUpdatePayload.$_createMessage)
    ..aOM<SyncMetadataPayload>(12, _omitFieldNames ? '' : 'syncMetadata',
        subBuilder: SyncMetadataPayload.$_createMessage)
    ..aOM<MerkleRootPayload>(13, _omitFieldNames ? '' : 'merkleRoot',
        subBuilder: MerkleRootPayload.$_createMessage)
    ..aOM<MerkleNodePayload>(14, _omitFieldNames ? '' : 'merkleNode',
        subBuilder: MerkleNodePayload.$_createMessage)
    ..aOM<SingleOperationPayload>(15, _omitFieldNames ? '' : 'singleOperation',
        subBuilder: SingleOperationPayload.$_createMessage)
    ..aOM<GetMerkleNodeRequest>(16, _omitFieldNames ? '' : 'getMerkleNode',
        subBuilder: GetMerkleNodeRequest.$_createMessage)
    ..aOM<GetEntitiesInRangeRequest>(
        17, _omitFieldNames ? '' : 'getEntitiesInRange',
        subBuilder: GetEntitiesInRangeRequest.$_createMessage)
    ..aOM<SolverRequest>(20, _omitFieldNames ? '' : 'solverRequest',
        subBuilder: SolverRequest.$_createMessage)
    ..aOM<SolverResponse>(21, _omitFieldNames ? '' : 'solverResponse',
        subBuilder: SolverResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolMessage copyWith(void Function(ProtocolMessage) updates) =>
      super.copyWith((message) => updates(message as ProtocolMessage))
          as ProtocolMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProtocolMessage() / ProtocolMessage.new instead')
  static ProtocolMessage create() => ProtocolMessage._();
  static $pb.GeneratedMessage $_createMessage() => ProtocolMessage._();
  @$core.override
  ProtocolMessage createEmptyInstance() => ProtocolMessage._();
  @$core.pragma('dart2js:noInline')
  static ProtocolMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProtocolMessage>(
          ProtocolMessage.$_createMessage);
  static ProtocolMessage? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  ProtocolMessage_Payload whichPayload() =>
      _ProtocolMessage_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get channel => $_getSZ(1);
  @$pb.TagNumber(2)
  set channel($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannel() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get timestamp => $_getSZ(2);
  @$pb.TagNumber(3)
  set timestamp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get actorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set actorId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActorId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);

  @$pb.TagNumber(10)
  SubscribeRequest get subscribe => $_getN(5);
  @$pb.TagNumber(10)
  set subscribe(SubscribeRequest value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSubscribe() => $_has(5);
  @$pb.TagNumber(10)
  void clearSubscribe() => $_clearField(10);
  @$pb.TagNumber(10)
  SubscribeRequest ensureSubscribe() => $_ensure(5);

  @$pb.TagNumber(11)
  BatchUpdatePayload get batchUpdate => $_getN(6);
  @$pb.TagNumber(11)
  set batchUpdate(BatchUpdatePayload value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasBatchUpdate() => $_has(6);
  @$pb.TagNumber(11)
  void clearBatchUpdate() => $_clearField(11);
  @$pb.TagNumber(11)
  BatchUpdatePayload ensureBatchUpdate() => $_ensure(6);

  @$pb.TagNumber(12)
  SyncMetadataPayload get syncMetadata => $_getN(7);
  @$pb.TagNumber(12)
  set syncMetadata(SyncMetadataPayload value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasSyncMetadata() => $_has(7);
  @$pb.TagNumber(12)
  void clearSyncMetadata() => $_clearField(12);
  @$pb.TagNumber(12)
  SyncMetadataPayload ensureSyncMetadata() => $_ensure(7);

  @$pb.TagNumber(13)
  MerkleRootPayload get merkleRoot => $_getN(8);
  @$pb.TagNumber(13)
  set merkleRoot(MerkleRootPayload value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasMerkleRoot() => $_has(8);
  @$pb.TagNumber(13)
  void clearMerkleRoot() => $_clearField(13);
  @$pb.TagNumber(13)
  MerkleRootPayload ensureMerkleRoot() => $_ensure(8);

  @$pb.TagNumber(14)
  MerkleNodePayload get merkleNode => $_getN(9);
  @$pb.TagNumber(14)
  set merkleNode(MerkleNodePayload value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasMerkleNode() => $_has(9);
  @$pb.TagNumber(14)
  void clearMerkleNode() => $_clearField(14);
  @$pb.TagNumber(14)
  MerkleNodePayload ensureMerkleNode() => $_ensure(9);

  @$pb.TagNumber(15)
  SingleOperationPayload get singleOperation => $_getN(10);
  @$pb.TagNumber(15)
  set singleOperation(SingleOperationPayload value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasSingleOperation() => $_has(10);
  @$pb.TagNumber(15)
  void clearSingleOperation() => $_clearField(15);
  @$pb.TagNumber(15)
  SingleOperationPayload ensureSingleOperation() => $_ensure(10);

  @$pb.TagNumber(16)
  GetMerkleNodeRequest get getMerkleNode => $_getN(11);
  @$pb.TagNumber(16)
  set getMerkleNode(GetMerkleNodeRequest value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasGetMerkleNode() => $_has(11);
  @$pb.TagNumber(16)
  void clearGetMerkleNode() => $_clearField(16);
  @$pb.TagNumber(16)
  GetMerkleNodeRequest ensureGetMerkleNode() => $_ensure(11);

  @$pb.TagNumber(17)
  GetEntitiesInRangeRequest get getEntitiesInRange => $_getN(12);
  @$pb.TagNumber(17)
  set getEntitiesInRange(GetEntitiesInRangeRequest value) =>
      $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasGetEntitiesInRange() => $_has(12);
  @$pb.TagNumber(17)
  void clearGetEntitiesInRange() => $_clearField(17);
  @$pb.TagNumber(17)
  GetEntitiesInRangeRequest ensureGetEntitiesInRange() => $_ensure(12);

  @$pb.TagNumber(20)
  SolverRequest get solverRequest => $_getN(13);
  @$pb.TagNumber(20)
  set solverRequest(SolverRequest value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasSolverRequest() => $_has(13);
  @$pb.TagNumber(20)
  void clearSolverRequest() => $_clearField(20);
  @$pb.TagNumber(20)
  SolverRequest ensureSolverRequest() => $_ensure(13);

  @$pb.TagNumber(21)
  SolverResponse get solverResponse => $_getN(14);
  @$pb.TagNumber(21)
  set solverResponse(SolverResponse value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasSolverResponse() => $_has(14);
  @$pb.TagNumber(21)
  void clearSolverResponse() => $_clearField(21);
  @$pb.TagNumber(21)
  SolverResponse ensureSolverResponse() => $_ensure(14);
}

class SolverRequest extends $pb.GeneratedMessage {
  factory SolverRequest({
    $core.Iterable<ProtocolTask>? tasks,
    $core.Iterable<ProtocolDependency>? dependencies,
    $core.int? algorithmLevel,
  }) {
    final result = SolverRequest._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (dependencies != null) result.dependencies.addAll(dependencies);
    if (algorithmLevel != null) result.algorithmLevel = algorithmLevel;
    return result;
  }

  SolverRequest._();

  factory SolverRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SolverRequest()..mergeFromBuffer(data, registry);
  factory SolverRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SolverRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SolverRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: SolverRequest.$_createMessage)
    ..pPM<ProtocolTask>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: ProtocolTask.$_createMessage)
    ..pPM<ProtocolDependency>(2, _omitFieldNames ? '' : 'dependencies',
        subBuilder: ProtocolDependency.$_createMessage)
    ..aI(3, _omitFieldNames ? '' : 'algorithmLevel',
        protoName: 'algorithmLevel')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SolverRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SolverRequest copyWith(void Function(SolverRequest) updates) =>
      super.copyWith((message) => updates(message as SolverRequest))
          as SolverRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SolverRequest() / SolverRequest.new instead')
  static SolverRequest create() => SolverRequest._();
  static $pb.GeneratedMessage $_createMessage() => SolverRequest._();
  @$core.override
  SolverRequest createEmptyInstance() => SolverRequest._();
  @$core.pragma('dart2js:noInline')
  static SolverRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SolverRequest>(
          SolverRequest.$_createMessage);
  static SolverRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProtocolTask> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<ProtocolDependency> get dependencies => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get algorithmLevel => $_getIZ(2);
  @$pb.TagNumber(3)
  set algorithmLevel($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAlgorithmLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearAlgorithmLevel() => $_clearField(3);
}

class SolverResponse extends $pb.GeneratedMessage {
  factory SolverResponse({
    $core.bool? success,
    $core.String? errorMessage,
    $core.Iterable<ProtocolTask>? tasks,
  }) {
    final result = SolverResponse._();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  SolverResponse._();

  factory SolverResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SolverResponse()..mergeFromBuffer(data, registry);
  factory SolverResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SolverResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SolverResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gantt_protocol'),
      createEmptyInstance: SolverResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage', protoName: 'errorMessage')
    ..pPM<ProtocolTask>(3, _omitFieldNames ? '' : 'tasks',
        subBuilder: ProtocolTask.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SolverResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SolverResponse copyWith(void Function(SolverResponse) updates) =>
      super.copyWith((message) => updates(message as SolverResponse))
          as SolverResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SolverResponse() / SolverResponse.new instead')
  static SolverResponse create() => SolverResponse._();
  static $pb.GeneratedMessage $_createMessage() => SolverResponse._();
  @$core.override
  SolverResponse createEmptyInstance() => SolverResponse._();
  @$core.pragma('dart2js:noInline')
  static SolverResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SolverResponse>(
          SolverResponse.$_createMessage);
  static SolverResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<ProtocolTask> get tasks => $_getList(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
