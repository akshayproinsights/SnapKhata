// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BillsTable extends Bills with TableInfo<$BillsTable, Bill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _supabaseIdMeta =
      const VerificationMeta('supabaseId');
  @override
  late final GeneratedColumn<String> supabaseId = GeneratedColumn<String>(
      'supabase_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceTypeMeta =
      const VerificationMeta('invoiceType');
  @override
  late final GeneratedColumn<String> invoiceType = GeneratedColumn<String>(
      'invoice_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('order_summary'));
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _amountPaidMeta =
      const VerificationMeta('amountPaid');
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
      'amount_paid', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _amountRemainingMeta =
      const VerificationMeta('amountRemaining');
  @override
  late final GeneratedColumn<double> amountRemaining = GeneratedColumn<double>(
      'amount_remaining', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _rawImagePathMeta =
      const VerificationMeta('rawImagePath');
  @override
  late final GeneratedColumn<String> rawImagePath = GeneratedColumn<String>(
      'raw_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        supabaseId,
        customerName,
        customerPhone,
        invoiceType,
        totalAmount,
        amountPaid,
        amountRemaining,
        status,
        rawImagePath,
        isSynced,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(Insertable<Bill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supabase_id')) {
      context.handle(
          _supabaseIdMeta,
          supabaseId.isAcceptableOrUnknown(
              data['supabase_id']!, _supabaseIdMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    }
    if (data.containsKey('invoice_type')) {
      context.handle(
          _invoiceTypeMeta,
          invoiceType.isAcceptableOrUnknown(
              data['invoice_type']!, _invoiceTypeMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
          _amountPaidMeta,
          amountPaid.isAcceptableOrUnknown(
              data['amount_paid']!, _amountPaidMeta));
    }
    if (data.containsKey('amount_remaining')) {
      context.handle(
          _amountRemainingMeta,
          amountRemaining.isAcceptableOrUnknown(
              data['amount_remaining']!, _amountRemainingMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('raw_image_path')) {
      context.handle(
          _rawImagePathMeta,
          rawImagePath.isAcceptableOrUnknown(
              data['raw_image_path']!, _rawImagePathMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      supabaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supabase_id']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone']),
      invoiceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_type'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      amountPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_paid'])!,
      amountRemaining: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}amount_remaining']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      rawImagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_image_path']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class Bill extends DataClass implements Insertable<Bill> {
  final int id;
  final String? supabaseId;
  final String customerName;
  final String? customerPhone;
  final String invoiceType;
  final double totalAmount;
  final double amountPaid;
  final double? amountRemaining;
  final String status;
  final String? rawImagePath;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Bill(
      {required this.id,
      this.supabaseId,
      required this.customerName,
      this.customerPhone,
      required this.invoiceType,
      required this.totalAmount,
      required this.amountPaid,
      this.amountRemaining,
      required this.status,
      this.rawImagePath,
      required this.isSynced,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || supabaseId != null) {
      map['supabase_id'] = Variable<String>(supabaseId);
    }
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    map['invoice_type'] = Variable<String>(invoiceType);
    map['total_amount'] = Variable<double>(totalAmount);
    map['amount_paid'] = Variable<double>(amountPaid);
    if (!nullToAbsent || amountRemaining != null) {
      map['amount_remaining'] = Variable<double>(amountRemaining);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || rawImagePath != null) {
      map['raw_image_path'] = Variable<String>(rawImagePath);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      supabaseId: supabaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseId),
      customerName: Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      invoiceType: Value(invoiceType),
      totalAmount: Value(totalAmount),
      amountPaid: Value(amountPaid),
      amountRemaining: amountRemaining == null && nullToAbsent
          ? const Value.absent()
          : Value(amountRemaining),
      status: Value(status),
      rawImagePath: rawImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(rawImagePath),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Bill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bill(
      id: serializer.fromJson<int>(json['id']),
      supabaseId: serializer.fromJson<String?>(json['supabaseId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      invoiceType: serializer.fromJson<String>(json['invoiceType']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      amountRemaining: serializer.fromJson<double?>(json['amountRemaining']),
      status: serializer.fromJson<String>(json['status']),
      rawImagePath: serializer.fromJson<String?>(json['rawImagePath']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supabaseId': serializer.toJson<String?>(supabaseId),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'invoiceType': serializer.toJson<String>(invoiceType),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'amountRemaining': serializer.toJson<double?>(amountRemaining),
      'status': serializer.toJson<String>(status),
      'rawImagePath': serializer.toJson<String?>(rawImagePath),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Bill copyWith(
          {int? id,
          Value<String?> supabaseId = const Value.absent(),
          String? customerName,
          Value<String?> customerPhone = const Value.absent(),
          String? invoiceType,
          double? totalAmount,
          double? amountPaid,
          Value<double?> amountRemaining = const Value.absent(),
          String? status,
          Value<String?> rawImagePath = const Value.absent(),
          bool? isSynced,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Bill(
        id: id ?? this.id,
        supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,
        customerName: customerName ?? this.customerName,
        customerPhone:
            customerPhone.present ? customerPhone.value : this.customerPhone,
        invoiceType: invoiceType ?? this.invoiceType,
        totalAmount: totalAmount ?? this.totalAmount,
        amountPaid: amountPaid ?? this.amountPaid,
        amountRemaining: amountRemaining.present
            ? amountRemaining.value
            : this.amountRemaining,
        status: status ?? this.status,
        rawImagePath:
            rawImagePath.present ? rawImagePath.value : this.rawImagePath,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Bill copyWithCompanion(BillsCompanion data) {
    return Bill(
      id: data.id.present ? data.id.value : this.id,
      supabaseId:
          data.supabaseId.present ? data.supabaseId.value : this.supabaseId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      invoiceType:
          data.invoiceType.present ? data.invoiceType.value : this.invoiceType,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      amountPaid:
          data.amountPaid.present ? data.amountPaid.value : this.amountPaid,
      amountRemaining: data.amountRemaining.present
          ? data.amountRemaining.value
          : this.amountRemaining,
      status: data.status.present ? data.status.value : this.status,
      rawImagePath: data.rawImagePath.present
          ? data.rawImagePath.value
          : this.rawImagePath,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bill(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountRemaining: $amountRemaining, ')
          ..write('status: $status, ')
          ..write('rawImagePath: $rawImagePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      supabaseId,
      customerName,
      customerPhone,
      invoiceType,
      totalAmount,
      amountPaid,
      amountRemaining,
      status,
      rawImagePath,
      isSynced,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill &&
          other.id == this.id &&
          other.supabaseId == this.supabaseId &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.invoiceType == this.invoiceType &&
          other.totalAmount == this.totalAmount &&
          other.amountPaid == this.amountPaid &&
          other.amountRemaining == this.amountRemaining &&
          other.status == this.status &&
          other.rawImagePath == this.rawImagePath &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BillsCompanion extends UpdateCompanion<Bill> {
  final Value<int> id;
  final Value<String?> supabaseId;
  final Value<String> customerName;
  final Value<String?> customerPhone;
  final Value<String> invoiceType;
  final Value<double> totalAmount;
  final Value<double> amountPaid;
  final Value<double?> amountRemaining;
  final Value<String> status;
  final Value<String?> rawImagePath;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountRemaining = const Value.absent(),
    this.status = const Value.absent(),
    this.rawImagePath = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BillsCompanion.insert({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountRemaining = const Value.absent(),
    this.status = const Value.absent(),
    this.rawImagePath = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<Bill> custom({
    Expression<int>? id,
    Expression<String>? supabaseId,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? invoiceType,
    Expression<double>? totalAmount,
    Expression<double>? amountPaid,
    Expression<double>? amountRemaining,
    Expression<String>? status,
    Expression<String>? rawImagePath,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supabaseId != null) 'supabase_id': supabaseId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (amountRemaining != null) 'amount_remaining': amountRemaining,
      if (status != null) 'status': status,
      if (rawImagePath != null) 'raw_image_path': rawImagePath,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BillsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? supabaseId,
      Value<String>? customerName,
      Value<String?>? customerPhone,
      Value<String>? invoiceType,
      Value<double>? totalAmount,
      Value<double>? amountPaid,
      Value<double?>? amountRemaining,
      Value<String>? status,
      Value<String?>? rawImagePath,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return BillsCompanion(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      invoiceType: invoiceType ?? this.invoiceType,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountRemaining: amountRemaining ?? this.amountRemaining,
      status: status ?? this.status,
      rawImagePath: rawImagePath ?? this.rawImagePath,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supabaseId.present) {
      map['supabase_id'] = Variable<String>(supabaseId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (invoiceType.present) {
      map['invoice_type'] = Variable<String>(invoiceType.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (amountRemaining.present) {
      map['amount_remaining'] = Variable<double>(amountRemaining.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rawImagePath.present) {
      map['raw_image_path'] = Variable<String>(rawImagePath.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountRemaining: $amountRemaining, ')
          ..write('status: $status, ')
          ..write('rawImagePath: $rawImagePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BillItemsTable extends BillItems
    with TableInfo<$BillItemsTable, BillItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<int> billId = GeneratedColumn<int>(
      'bill_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES bills (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
      'total_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, billId, name, quantity, unit, unitPrice, totalPrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_items';
  @override
  VerificationContext validateIntegrity(Insertable<BillItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bill_id')) {
      context.handle(_billIdMeta,
          billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta));
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      billId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bill_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_price'])!,
    );
  }

  @override
  $BillItemsTable createAlias(String alias) {
    return $BillItemsTable(attachedDatabase, alias);
  }
}

class BillItem extends DataClass implements Insertable<BillItem> {
  final int id;
  final int billId;
  final String name;
  final double quantity;
  final String? unit;
  final double unitPrice;
  final double totalPrice;
  const BillItem(
      {required this.id,
      required this.billId,
      required this.name,
      required this.quantity,
      this.unit,
      required this.unitPrice,
      required this.totalPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_id'] = Variable<int>(billId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    return map;
  }

  BillItemsCompanion toCompanion(bool nullToAbsent) {
    return BillItemsCompanion(
      id: Value(id),
      billId: Value(billId),
      name: Value(name),
      quantity: Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
    );
  }

  factory BillItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillItem(
      id: serializer.fromJson<int>(json['id']),
      billId: serializer.fromJson<int>(json['billId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'billId': serializer.toJson<int>(billId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
    };
  }

  BillItem copyWith(
          {int? id,
          int? billId,
          String? name,
          double? quantity,
          Value<String?> unit = const Value.absent(),
          double? unitPrice,
          double? totalPrice}) =>
      BillItem(
        id: id ?? this.id,
        billId: billId ?? this.billId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit.present ? unit.value : this.unit,
        unitPrice: unitPrice ?? this.unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
      );
  BillItem copyWithCompanion(BillItemsCompanion data) {
    return BillItem(
      id: data.id.present ? data.id.value : this.id,
      billId: data.billId.present ? data.billId.value : this.billId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillItem(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, billId, name, quantity, unit, unitPrice, totalPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillItem &&
          other.id == this.id &&
          other.billId == this.billId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice);
}

class BillItemsCompanion extends UpdateCompanion<BillItem> {
  final Value<int> id;
  final Value<int> billId;
  final Value<String> name;
  final Value<double> quantity;
  final Value<String?> unit;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  const BillItemsCompanion({
    this.id = const Value.absent(),
    this.billId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
  });
  BillItemsCompanion.insert({
    this.id = const Value.absent(),
    required int billId,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
  })  : billId = Value(billId),
        name = Value(name);
  static Insertable<BillItem> custom({
    Expression<int>? id,
    Expression<int>? billId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billId != null) 'bill_id': billId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
    });
  }

  BillItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? billId,
      Value<String>? name,
      Value<double>? quantity,
      Value<String?>? unit,
      Value<double>? unitPrice,
      Value<double>? totalPrice}) {
    return BillItemsCompanion(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<int>(billId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillItemsCompanion(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _normalizedNameMeta =
      const VerificationMeta('normalizedName');
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
      'normalized_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastPriceMeta =
      const VerificationMeta('lastPrice');
  @override
  late final GeneratedColumn<double> lastPrice = GeneratedColumn<double>(
      'last_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pcs'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timesOrderedMeta =
      const VerificationMeta('timesOrdered');
  @override
  late final GeneratedColumn<int> timesOrdered = GeneratedColumn<int>(
      'times_ordered', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastSeenAtMeta =
      const VerificationMeta('lastSeenAt');
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
      'last_seen_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        normalizedName,
        lastPrice,
        unit,
        category,
        timesOrdered,
        lastSeenAt,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
          _normalizedNameMeta,
          normalizedName.isAcceptableOrUnknown(
              data['normalized_name']!, _normalizedNameMeta));
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('last_price')) {
      context.handle(_lastPriceMeta,
          lastPrice.isAcceptableOrUnknown(data['last_price']!, _lastPriceMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('times_ordered')) {
      context.handle(
          _timesOrderedMeta,
          timesOrdered.isAcceptableOrUnknown(
              data['times_ordered']!, _timesOrderedMeta));
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
          _lastSeenAtMeta,
          lastSeenAt.isAcceptableOrUnknown(
              data['last_seen_at']!, _lastSeenAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      normalizedName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_name'])!,
      lastPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}last_price'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      timesOrdered: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times_ordered'])!,
      lastSeenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItem extends DataClass implements Insertable<CatalogItem> {
  final int id;
  final String name;
  final String normalizedName;
  final double lastPrice;
  final String unit;
  final String? category;
  final int timesOrdered;
  final DateTime lastSeenAt;
  final bool isSynced;
  const CatalogItem(
      {required this.id,
      required this.name,
      required this.normalizedName,
      required this.lastPrice,
      required this.unit,
      this.category,
      required this.timesOrdered,
      required this.lastSeenAt,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['last_price'] = Variable<double>(lastPrice);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['times_ordered'] = Variable<int>(timesOrdered);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      lastPrice: Value(lastPrice),
      unit: Value(unit),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      timesOrdered: Value(timesOrdered),
      lastSeenAt: Value(lastSeenAt),
      isSynced: Value(isSynced),
    );
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      lastPrice: serializer.fromJson<double>(json['lastPrice']),
      unit: serializer.fromJson<String>(json['unit']),
      category: serializer.fromJson<String?>(json['category']),
      timesOrdered: serializer.fromJson<int>(json['timesOrdered']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'lastPrice': serializer.toJson<double>(lastPrice),
      'unit': serializer.toJson<String>(unit),
      'category': serializer.toJson<String?>(category),
      'timesOrdered': serializer.toJson<int>(timesOrdered),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  CatalogItem copyWith(
          {int? id,
          String? name,
          String? normalizedName,
          double? lastPrice,
          String? unit,
          Value<String?> category = const Value.absent(),
          int? timesOrdered,
          DateTime? lastSeenAt,
          bool? isSynced}) =>
      CatalogItem(
        id: id ?? this.id,
        name: name ?? this.name,
        normalizedName: normalizedName ?? this.normalizedName,
        lastPrice: lastPrice ?? this.lastPrice,
        unit: unit ?? this.unit,
        category: category.present ? category.value : this.category,
        timesOrdered: timesOrdered ?? this.timesOrdered,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        isSynced: isSynced ?? this.isSynced,
      );
  CatalogItem copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      lastPrice: data.lastPrice.present ? data.lastPrice.value : this.lastPrice,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      timesOrdered: data.timesOrdered.present
          ? data.timesOrdered.value
          : this.timesOrdered,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('lastPrice: $lastPrice, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('timesOrdered: $timesOrdered, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, normalizedName, lastPrice, unit,
      category, timesOrdered, lastSeenAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.lastPrice == this.lastPrice &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.timesOrdered == this.timesOrdered &&
          other.lastSeenAt == this.lastSeenAt &&
          other.isSynced == this.isSynced);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<double> lastPrice;
  final Value<String> unit;
  final Value<String?> category;
  final Value<int> timesOrdered;
  final Value<DateTime> lastSeenAt;
  final Value<bool> isSynced;
  const CatalogItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.lastPrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.timesOrdered = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String normalizedName,
    this.lastPrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.timesOrdered = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  })  : name = Value(name),
        normalizedName = Value(normalizedName);
  static Insertable<CatalogItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<double>? lastPrice,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<int>? timesOrdered,
    Expression<DateTime>? lastSeenAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (lastPrice != null) 'last_price': lastPrice,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (timesOrdered != null) 'times_ordered': timesOrdered,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  CatalogItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? normalizedName,
      Value<double>? lastPrice,
      Value<String>? unit,
      Value<String?>? category,
      Value<int>? timesOrdered,
      Value<DateTime>? lastSeenAt,
      Value<bool>? isSynced}) {
    return CatalogItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      lastPrice: lastPrice ?? this.lastPrice,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      timesOrdered: timesOrdered ?? this.timesOrdered,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (lastPrice.present) {
      map['last_price'] = Variable<double>(lastPrice.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (timesOrdered.present) {
      map['times_ordered'] = Variable<int>(timesOrdered.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('lastPrice: $lastPrice, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('timesOrdered: $timesOrdered, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _supabaseIdMeta =
      const VerificationMeta('supabaseId');
  @override
  late final GeneratedColumn<String> supabaseId = GeneratedColumn<String>(
      'supabase_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalPurchasesMeta =
      const VerificationMeta('totalPurchases');
  @override
  late final GeneratedColumn<double> totalPurchases = GeneratedColumn<double>(
      'total_purchases', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastPurchaseAtMeta =
      const VerificationMeta('lastPurchaseAt');
  @override
  late final GeneratedColumn<DateTime> lastPurchaseAt =
      GeneratedColumn<DateTime>('last_purchase_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        supabaseId,
        name,
        phone,
        totalPurchases,
        lastPurchaseAt,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supabase_id')) {
      context.handle(
          _supabaseIdMeta,
          supabaseId.isAcceptableOrUnknown(
              data['supabase_id']!, _supabaseIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('total_purchases')) {
      context.handle(
          _totalPurchasesMeta,
          totalPurchases.isAcceptableOrUnknown(
              data['total_purchases']!, _totalPurchasesMeta));
    }
    if (data.containsKey('last_purchase_at')) {
      context.handle(
          _lastPurchaseAtMeta,
          lastPurchaseAt.isAcceptableOrUnknown(
              data['last_purchase_at']!, _lastPurchaseAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      supabaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supabase_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      totalPurchases: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_purchases'])!,
      lastPurchaseAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_purchase_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String? supabaseId;
  final String name;
  final String? phone;
  final double totalPurchases;
  final DateTime? lastPurchaseAt;
  final bool isSynced;
  final DateTime createdAt;
  const Customer(
      {required this.id,
      this.supabaseId,
      required this.name,
      this.phone,
      required this.totalPurchases,
      this.lastPurchaseAt,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || supabaseId != null) {
      map['supabase_id'] = Variable<String>(supabaseId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['total_purchases'] = Variable<double>(totalPurchases);
    if (!nullToAbsent || lastPurchaseAt != null) {
      map['last_purchase_at'] = Variable<DateTime>(lastPurchaseAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      supabaseId: supabaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseId),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      totalPurchases: Value(totalPurchases),
      lastPurchaseAt: lastPurchaseAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPurchaseAt),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      supabaseId: serializer.fromJson<String?>(json['supabaseId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      totalPurchases: serializer.fromJson<double>(json['totalPurchases']),
      lastPurchaseAt: serializer.fromJson<DateTime?>(json['lastPurchaseAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supabaseId': serializer.toJson<String?>(supabaseId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'totalPurchases': serializer.toJson<double>(totalPurchases),
      'lastPurchaseAt': serializer.toJson<DateTime?>(lastPurchaseAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith(
          {int? id,
          Value<String?> supabaseId = const Value.absent(),
          String? name,
          Value<String?> phone = const Value.absent(),
          double? totalPurchases,
          Value<DateTime?> lastPurchaseAt = const Value.absent(),
          bool? isSynced,
          DateTime? createdAt}) =>
      Customer(
        id: id ?? this.id,
        supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        totalPurchases: totalPurchases ?? this.totalPurchases,
        lastPurchaseAt:
            lastPurchaseAt.present ? lastPurchaseAt.value : this.lastPurchaseAt,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      supabaseId:
          data.supabaseId.present ? data.supabaseId.value : this.supabaseId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      totalPurchases: data.totalPurchases.present
          ? data.totalPurchases.value
          : this.totalPurchases,
      lastPurchaseAt: data.lastPurchaseAt.present
          ? data.lastPurchaseAt.value
          : this.lastPurchaseAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('totalPurchases: $totalPurchases, ')
          ..write('lastPurchaseAt: $lastPurchaseAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, supabaseId, name, phone, totalPurchases,
      lastPurchaseAt, isSynced, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.supabaseId == this.supabaseId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.totalPurchases == this.totalPurchases &&
          other.lastPurchaseAt == this.lastPurchaseAt &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String?> supabaseId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<double> totalPurchases;
  final Value<DateTime?> lastPurchaseAt;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.totalPurchases = const Value.absent(),
    this.lastPurchaseAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.totalPurchases = const Value.absent(),
    this.lastPurchaseAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? supabaseId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<double>? totalPurchases,
    Expression<DateTime>? lastPurchaseAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supabaseId != null) 'supabase_id': supabaseId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (totalPurchases != null) 'total_purchases': totalPurchases,
      if (lastPurchaseAt != null) 'last_purchase_at': lastPurchaseAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersCompanion copyWith(
      {Value<int>? id,
      Value<String?>? supabaseId,
      Value<String>? name,
      Value<String?>? phone,
      Value<double>? totalPurchases,
      Value<DateTime?>? lastPurchaseAt,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt}) {
    return CustomersCompanion(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      lastPurchaseAt: lastPurchaseAt ?? this.lastPurchaseAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supabaseId.present) {
      map['supabase_id'] = Variable<String>(supabaseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (totalPurchases.present) {
      map['total_purchases'] = Variable<double>(totalPurchases.value);
    }
    if (lastPurchaseAt.present) {
      map['last_purchase_at'] = Variable<DateTime>(lastPurchaseAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('totalPurchases: $totalPurchases, ')
          ..write('lastPurchaseAt: $lastPurchaseAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _supabaseIdMeta =
      const VerificationMeta('supabaseId');
  @override
  late final GeneratedColumn<String> supabaseId = GeneratedColumn<String>(
      'supabase_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
      'paid_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        supabaseId,
        customerPhone,
        customerName,
        amount,
        note,
        isSynced,
        paidAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supabase_id')) {
      context.handle(
          _supabaseIdMeta,
          supabaseId.isAcceptableOrUnknown(
              data['supabase_id']!, _supabaseIdMeta));
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('paid_at')) {
      context.handle(_paidAtMeta,
          paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      supabaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supabase_id']),
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      paidAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paid_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final String? supabaseId;
  final String? customerPhone;
  final String customerName;
  final double amount;
  final String? note;
  final bool isSynced;
  final DateTime paidAt;
  final DateTime createdAt;
  const Payment(
      {required this.id,
      this.supabaseId,
      this.customerPhone,
      required this.customerName,
      required this.amount,
      this.note,
      required this.isSynced,
      required this.paidAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || supabaseId != null) {
      map['supabase_id'] = Variable<String>(supabaseId);
    }
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    map['customer_name'] = Variable<String>(customerName);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['paid_at'] = Variable<DateTime>(paidAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      supabaseId: supabaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseId),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      customerName: Value(customerName),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isSynced: Value(isSynced),
      paidAt: Value(paidAt),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      supabaseId: serializer.fromJson<String?>(json['supabaseId']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      customerName: serializer.fromJson<String>(json['customerName']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supabaseId': serializer.toJson<String?>(supabaseId),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'customerName': serializer.toJson<String>(customerName),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String?>(note),
      'isSynced': serializer.toJson<bool>(isSynced),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith(
          {int? id,
          Value<String?> supabaseId = const Value.absent(),
          Value<String?> customerPhone = const Value.absent(),
          String? customerName,
          double? amount,
          Value<String?> note = const Value.absent(),
          bool? isSynced,
          DateTime? paidAt,
          DateTime? createdAt}) =>
      Payment(
        id: id ?? this.id,
        supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,
        customerPhone:
            customerPhone.present ? customerPhone.value : this.customerPhone,
        customerName: customerName ?? this.customerName,
        amount: amount ?? this.amount,
        note: note.present ? note.value : this.note,
        isSynced: isSynced ?? this.isSynced,
        paidAt: paidAt ?? this.paidAt,
        createdAt: createdAt ?? this.createdAt,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      supabaseId:
          data.supabaseId.present ? data.supabaseId.value : this.supabaseId,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('customerName: $customerName, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('isSynced: $isSynced, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, supabaseId, customerPhone, customerName,
      amount, note, isSynced, paidAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.supabaseId == this.supabaseId &&
          other.customerPhone == this.customerPhone &&
          other.customerName == this.customerName &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.isSynced == this.isSynced &&
          other.paidAt == this.paidAt &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<String?> supabaseId;
  final Value<String?> customerPhone;
  final Value<String> customerName;
  final Value<double> amount;
  final Value<String?> note;
  final Value<bool> isSynced;
  final Value<DateTime> paidAt;
  final Value<DateTime> createdAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.customerName = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.customerName = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<String>? supabaseId,
    Expression<String>? customerPhone,
    Expression<String>? customerName,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<bool>? isSynced,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supabaseId != null) 'supabase_id': supabaseId,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (customerName != null) 'customer_name': customerName,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (isSynced != null) 'is_synced': isSynced,
      if (paidAt != null) 'paid_at': paidAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? supabaseId,
      Value<String?>? customerPhone,
      Value<String>? customerName,
      Value<double>? amount,
      Value<String?>? note,
      Value<bool>? isSynced,
      Value<DateTime>? paidAt,
      Value<DateTime>? createdAt}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      isSynced: isSynced ?? this.isSynced,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supabaseId.present) {
      map['supabase_id'] = Variable<String>(supabaseId.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('customerName: $customerName, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('isSynced: $isSynced, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShopProfilesTable extends ShopProfiles
    with TableInfo<$ShopProfilesTable, ShopProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _shopNameMeta =
      const VerificationMeta('shopName');
  @override
  late final GeneratedColumn<String> shopName = GeneratedColumn<String>(
      'shop_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('My Shop'));
  static const VerificationMeta _shopAddressMeta =
      const VerificationMeta('shopAddress');
  @override
  late final GeneratedColumn<String> shopAddress = GeneratedColumn<String>(
      'shop_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shopPhoneMeta =
      const VerificationMeta('shopPhone');
  @override
  late final GeneratedColumn<String> shopPhone = GeneratedColumn<String>(
      'shop_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shopGstNumberMeta =
      const VerificationMeta('shopGstNumber');
  @override
  late final GeneratedColumn<String> shopGstNumber = GeneratedColumn<String>(
      'shop_gst_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shopEmailMeta =
      const VerificationMeta('shopEmail');
  @override
  late final GeneratedColumn<String> shopEmail = GeneratedColumn<String>(
      'shop_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supabaseIdMeta =
      const VerificationMeta('supabaseId');
  @override
  late final GeneratedColumn<String> supabaseId = GeneratedColumn<String>(
      'supabase_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shopName,
        shopAddress,
        shopPhone,
        shopGstNumber,
        shopEmail,
        logoPath,
        supabaseId,
        isSynced,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<ShopProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shop_name')) {
      context.handle(_shopNameMeta,
          shopName.isAcceptableOrUnknown(data['shop_name']!, _shopNameMeta));
    }
    if (data.containsKey('shop_address')) {
      context.handle(
          _shopAddressMeta,
          shopAddress.isAcceptableOrUnknown(
              data['shop_address']!, _shopAddressMeta));
    }
    if (data.containsKey('shop_phone')) {
      context.handle(_shopPhoneMeta,
          shopPhone.isAcceptableOrUnknown(data['shop_phone']!, _shopPhoneMeta));
    }
    if (data.containsKey('shop_gst_number')) {
      context.handle(
          _shopGstNumberMeta,
          shopGstNumber.isAcceptableOrUnknown(
              data['shop_gst_number']!, _shopGstNumberMeta));
    }
    if (data.containsKey('shop_email')) {
      context.handle(_shopEmailMeta,
          shopEmail.isAcceptableOrUnknown(data['shop_email']!, _shopEmailMeta));
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('supabase_id')) {
      context.handle(
          _supabaseIdMeta,
          supabaseId.isAcceptableOrUnknown(
              data['supabase_id']!, _supabaseIdMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      shopName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_name'])!,
      shopAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_address']),
      shopPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_phone']),
      shopGstNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_gst_number']),
      shopEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_email']),
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      supabaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supabase_id']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ShopProfilesTable createAlias(String alias) {
    return $ShopProfilesTable(attachedDatabase, alias);
  }
}

class ShopProfile extends DataClass implements Insertable<ShopProfile> {
  final int id;
  final String shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopGstNumber;
  final String? shopEmail;
  final String? logoPath;
  final String? supabaseId;
  final bool isSynced;
  final DateTime updatedAt;
  const ShopProfile(
      {required this.id,
      required this.shopName,
      this.shopAddress,
      this.shopPhone,
      this.shopGstNumber,
      this.shopEmail,
      this.logoPath,
      this.supabaseId,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shop_name'] = Variable<String>(shopName);
    if (!nullToAbsent || shopAddress != null) {
      map['shop_address'] = Variable<String>(shopAddress);
    }
    if (!nullToAbsent || shopPhone != null) {
      map['shop_phone'] = Variable<String>(shopPhone);
    }
    if (!nullToAbsent || shopGstNumber != null) {
      map['shop_gst_number'] = Variable<String>(shopGstNumber);
    }
    if (!nullToAbsent || shopEmail != null) {
      map['shop_email'] = Variable<String>(shopEmail);
    }
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    if (!nullToAbsent || supabaseId != null) {
      map['supabase_id'] = Variable<String>(supabaseId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShopProfilesCompanion toCompanion(bool nullToAbsent) {
    return ShopProfilesCompanion(
      id: Value(id),
      shopName: Value(shopName),
      shopAddress: shopAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(shopAddress),
      shopPhone: shopPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(shopPhone),
      shopGstNumber: shopGstNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(shopGstNumber),
      shopEmail: shopEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(shopEmail),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      supabaseId: supabaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseId),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShopProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopProfile(
      id: serializer.fromJson<int>(json['id']),
      shopName: serializer.fromJson<String>(json['shopName']),
      shopAddress: serializer.fromJson<String?>(json['shopAddress']),
      shopPhone: serializer.fromJson<String?>(json['shopPhone']),
      shopGstNumber: serializer.fromJson<String?>(json['shopGstNumber']),
      shopEmail: serializer.fromJson<String?>(json['shopEmail']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      supabaseId: serializer.fromJson<String?>(json['supabaseId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shopName': serializer.toJson<String>(shopName),
      'shopAddress': serializer.toJson<String?>(shopAddress),
      'shopPhone': serializer.toJson<String?>(shopPhone),
      'shopGstNumber': serializer.toJson<String?>(shopGstNumber),
      'shopEmail': serializer.toJson<String?>(shopEmail),
      'logoPath': serializer.toJson<String?>(logoPath),
      'supabaseId': serializer.toJson<String?>(supabaseId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShopProfile copyWith(
          {int? id,
          String? shopName,
          Value<String?> shopAddress = const Value.absent(),
          Value<String?> shopPhone = const Value.absent(),
          Value<String?> shopGstNumber = const Value.absent(),
          Value<String?> shopEmail = const Value.absent(),
          Value<String?> logoPath = const Value.absent(),
          Value<String?> supabaseId = const Value.absent(),
          bool? isSynced,
          DateTime? updatedAt}) =>
      ShopProfile(
        id: id ?? this.id,
        shopName: shopName ?? this.shopName,
        shopAddress: shopAddress.present ? shopAddress.value : this.shopAddress,
        shopPhone: shopPhone.present ? shopPhone.value : this.shopPhone,
        shopGstNumber:
            shopGstNumber.present ? shopGstNumber.value : this.shopGstNumber,
        shopEmail: shopEmail.present ? shopEmail.value : this.shopEmail,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ShopProfile copyWithCompanion(ShopProfilesCompanion data) {
    return ShopProfile(
      id: data.id.present ? data.id.value : this.id,
      shopName: data.shopName.present ? data.shopName.value : this.shopName,
      shopAddress:
          data.shopAddress.present ? data.shopAddress.value : this.shopAddress,
      shopPhone: data.shopPhone.present ? data.shopPhone.value : this.shopPhone,
      shopGstNumber: data.shopGstNumber.present
          ? data.shopGstNumber.value
          : this.shopGstNumber,
      shopEmail: data.shopEmail.present ? data.shopEmail.value : this.shopEmail,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      supabaseId:
          data.supabaseId.present ? data.supabaseId.value : this.supabaseId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopProfile(')
          ..write('id: $id, ')
          ..write('shopName: $shopName, ')
          ..write('shopAddress: $shopAddress, ')
          ..write('shopPhone: $shopPhone, ')
          ..write('shopGstNumber: $shopGstNumber, ')
          ..write('shopEmail: $shopEmail, ')
          ..write('logoPath: $logoPath, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shopName, shopAddress, shopPhone,
      shopGstNumber, shopEmail, logoPath, supabaseId, isSynced, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopProfile &&
          other.id == this.id &&
          other.shopName == this.shopName &&
          other.shopAddress == this.shopAddress &&
          other.shopPhone == this.shopPhone &&
          other.shopGstNumber == this.shopGstNumber &&
          other.shopEmail == this.shopEmail &&
          other.logoPath == this.logoPath &&
          other.supabaseId == this.supabaseId &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class ShopProfilesCompanion extends UpdateCompanion<ShopProfile> {
  final Value<int> id;
  final Value<String> shopName;
  final Value<String?> shopAddress;
  final Value<String?> shopPhone;
  final Value<String?> shopGstNumber;
  final Value<String?> shopEmail;
  final Value<String?> logoPath;
  final Value<String?> supabaseId;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  const ShopProfilesCompanion({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.shopAddress = const Value.absent(),
    this.shopPhone = const Value.absent(),
    this.shopGstNumber = const Value.absent(),
    this.shopEmail = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ShopProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.shopAddress = const Value.absent(),
    this.shopPhone = const Value.absent(),
    this.shopGstNumber = const Value.absent(),
    this.shopEmail = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<ShopProfile> custom({
    Expression<int>? id,
    Expression<String>? shopName,
    Expression<String>? shopAddress,
    Expression<String>? shopPhone,
    Expression<String>? shopGstNumber,
    Expression<String>? shopEmail,
    Expression<String>? logoPath,
    Expression<String>? supabaseId,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopName != null) 'shop_name': shopName,
      if (shopAddress != null) 'shop_address': shopAddress,
      if (shopPhone != null) 'shop_phone': shopPhone,
      if (shopGstNumber != null) 'shop_gst_number': shopGstNumber,
      if (shopEmail != null) 'shop_email': shopEmail,
      if (logoPath != null) 'logo_path': logoPath,
      if (supabaseId != null) 'supabase_id': supabaseId,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ShopProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? shopName,
      Value<String?>? shopAddress,
      Value<String?>? shopPhone,
      Value<String?>? shopGstNumber,
      Value<String?>? shopEmail,
      Value<String?>? logoPath,
      Value<String?>? supabaseId,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt}) {
    return ShopProfilesCompanion(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      shopGstNumber: shopGstNumber ?? this.shopGstNumber,
      shopEmail: shopEmail ?? this.shopEmail,
      logoPath: logoPath ?? this.logoPath,
      supabaseId: supabaseId ?? this.supabaseId,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shopName.present) {
      map['shop_name'] = Variable<String>(shopName.value);
    }
    if (shopAddress.present) {
      map['shop_address'] = Variable<String>(shopAddress.value);
    }
    if (shopPhone.present) {
      map['shop_phone'] = Variable<String>(shopPhone.value);
    }
    if (shopGstNumber.present) {
      map['shop_gst_number'] = Variable<String>(shopGstNumber.value);
    }
    if (shopEmail.present) {
      map['shop_email'] = Variable<String>(shopEmail.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (supabaseId.present) {
      map['supabase_id'] = Variable<String>(supabaseId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopProfilesCompanion(')
          ..write('id: $id, ')
          ..write('shopName: $shopName, ')
          ..write('shopAddress: $shopAddress, ')
          ..write('shopPhone: $shopPhone, ')
          ..write('shopGstNumber: $shopGstNumber, ')
          ..write('shopEmail: $shopEmail, ')
          ..write('logoPath: $logoPath, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $BillItemsTable billItems = $BillItemsTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $ShopProfilesTable shopProfiles = $ShopProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [bills, billItems, catalogItems, customers, payments, shopProfiles];
}

typedef $$BillsTableCreateCompanionBuilder = BillsCompanion Function({
  Value<int> id,
  Value<String?> supabaseId,
  Value<String> customerName,
  Value<String?> customerPhone,
  Value<String> invoiceType,
  Value<double> totalAmount,
  Value<double> amountPaid,
  Value<double?> amountRemaining,
  Value<String> status,
  Value<String?> rawImagePath,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BillsTableUpdateCompanionBuilder = BillsCompanion Function({
  Value<int> id,
  Value<String?> supabaseId,
  Value<String> customerName,
  Value<String?> customerPhone,
  Value<String> invoiceType,
  Value<double> totalAmount,
  Value<double> amountPaid,
  Value<double?> amountRemaining,
  Value<String> status,
  Value<String?> rawImagePath,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$BillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BillsTable,
    Bill,
    $$BillsTableFilterComposer,
    $$BillsTableOrderingComposer,
    $$BillsTableCreateCompanionBuilder,
    $$BillsTableUpdateCompanionBuilder> {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BillsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BillsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String> invoiceType = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<double> amountPaid = const Value.absent(),
            Value<double?> amountRemaining = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> rawImagePath = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BillsCompanion(
            id: id,
            supabaseId: supabaseId,
            customerName: customerName,
            customerPhone: customerPhone,
            invoiceType: invoiceType,
            totalAmount: totalAmount,
            amountPaid: amountPaid,
            amountRemaining: amountRemaining,
            status: status,
            rawImagePath: rawImagePath,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String> invoiceType = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<double> amountPaid = const Value.absent(),
            Value<double?> amountRemaining = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> rawImagePath = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BillsCompanion.insert(
            id: id,
            supabaseId: supabaseId,
            customerName: customerName,
            customerPhone: customerPhone,
            invoiceType: invoiceType,
            totalAmount: totalAmount,
            amountPaid: amountPaid,
            amountRemaining: amountRemaining,
            status: status,
            rawImagePath: rawImagePath,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        ));
}

class $$BillsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get customerName => $state.composableBuilder(
      column: $state.table.customerName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get customerPhone => $state.composableBuilder(
      column: $state.table.customerPhone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get invoiceType => $state.composableBuilder(
      column: $state.table.invoiceType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalAmount => $state.composableBuilder(
      column: $state.table.totalAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amountPaid => $state.composableBuilder(
      column: $state.table.amountPaid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amountRemaining => $state.composableBuilder(
      column: $state.table.amountRemaining,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rawImagePath => $state.composableBuilder(
      column: $state.table.rawImagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter billItemsRefs(
      ComposableFilter Function($$BillItemsTableFilterComposer f) f) {
    final $$BillItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.billItems,
        getReferencedColumn: (t) => t.billId,
        builder: (joinBuilder, parentComposers) =>
            $$BillItemsTableFilterComposer(ComposerState(
                $state.db, $state.db.billItems, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$BillsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get customerName => $state.composableBuilder(
      column: $state.table.customerName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get customerPhone => $state.composableBuilder(
      column: $state.table.customerPhone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get invoiceType => $state.composableBuilder(
      column: $state.table.invoiceType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalAmount => $state.composableBuilder(
      column: $state.table.totalAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amountPaid => $state.composableBuilder(
      column: $state.table.amountPaid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amountRemaining => $state.composableBuilder(
      column: $state.table.amountRemaining,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rawImagePath => $state.composableBuilder(
      column: $state.table.rawImagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$BillItemsTableCreateCompanionBuilder = BillItemsCompanion Function({
  Value<int> id,
  required int billId,
  required String name,
  Value<double> quantity,
  Value<String?> unit,
  Value<double> unitPrice,
  Value<double> totalPrice,
});
typedef $$BillItemsTableUpdateCompanionBuilder = BillItemsCompanion Function({
  Value<int> id,
  Value<int> billId,
  Value<String> name,
  Value<double> quantity,
  Value<String?> unit,
  Value<double> unitPrice,
  Value<double> totalPrice,
});

class $$BillItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BillItemsTable,
    BillItem,
    $$BillItemsTableFilterComposer,
    $$BillItemsTableOrderingComposer,
    $$BillItemsTableCreateCompanionBuilder,
    $$BillItemsTableUpdateCompanionBuilder> {
  $$BillItemsTableTableManager(_$AppDatabase db, $BillItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BillItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BillItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> billId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
          }) =>
              BillItemsCompanion(
            id: id,
            billId: billId,
            name: name,
            quantity: quantity,
            unit: unit,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int billId,
            required String name,
            Value<double> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
          }) =>
              BillItemsCompanion.insert(
            id: id,
            billId: billId,
            name: name,
            quantity: quantity,
            unit: unit,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
        ));
}

class $$BillItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BillItemsTable> {
  $$BillItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get unitPrice => $state.composableBuilder(
      column: $state.table.unitPrice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalPrice => $state.composableBuilder(
      column: $state.table.totalPrice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.billId,
        referencedTable: $state.db.bills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$BillsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.bills, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$BillItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BillItemsTable> {
  $$BillItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get unitPrice => $state.composableBuilder(
      column: $state.table.unitPrice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalPrice => $state.composableBuilder(
      column: $state.table.totalPrice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.billId,
        referencedTable: $state.db.bills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$BillsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.bills, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<int> id,
  required String name,
  required String normalizedName,
  Value<double> lastPrice,
  Value<String> unit,
  Value<String?> category,
  Value<int> timesOrdered,
  Value<DateTime> lastSeenAt,
  Value<bool> isSynced,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> normalizedName,
  Value<double> lastPrice,
  Value<String> unit,
  Value<String?> category,
  Value<int> timesOrdered,
  Value<DateTime> lastSeenAt,
  Value<bool> isSynced,
});

class $$CatalogItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItem,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder> {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CatalogItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CatalogItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> normalizedName = const Value.absent(),
            Value<double> lastPrice = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> timesOrdered = const Value.absent(),
            Value<DateTime> lastSeenAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              CatalogItemsCompanion(
            id: id,
            name: name,
            normalizedName: normalizedName,
            lastPrice: lastPrice,
            unit: unit,
            category: category,
            timesOrdered: timesOrdered,
            lastSeenAt: lastSeenAt,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String normalizedName,
            Value<double> lastPrice = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> timesOrdered = const Value.absent(),
            Value<DateTime> lastSeenAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              CatalogItemsCompanion.insert(
            id: id,
            name: name,
            normalizedName: normalizedName,
            lastPrice: lastPrice,
            unit: unit,
            category: category,
            timesOrdered: timesOrdered,
            lastSeenAt: lastSeenAt,
            isSynced: isSynced,
          ),
        ));
}

class $$CatalogItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get normalizedName => $state.composableBuilder(
      column: $state.table.normalizedName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get lastPrice => $state.composableBuilder(
      column: $state.table.lastPrice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get timesOrdered => $state.composableBuilder(
      column: $state.table.timesOrdered,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CatalogItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get normalizedName => $state.composableBuilder(
      column: $state.table.normalizedName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get lastPrice => $state.composableBuilder(
      column: $state.table.lastPrice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get timesOrdered => $state.composableBuilder(
      column: $state.table.timesOrdered,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String?> supabaseId,
  required String name,
  Value<String?> phone,
  Value<double> totalPurchases,
  Value<DateTime?> lastPurchaseAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String?> supabaseId,
  Value<String> name,
  Value<String?> phone,
  Value<double> totalPurchases,
  Value<DateTime?> lastPurchaseAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
});

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CustomersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CustomersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<double> totalPurchases = const Value.absent(),
            Value<DateTime?> lastPurchaseAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            supabaseId: supabaseId,
            name: name,
            phone: phone,
            totalPurchases: totalPurchases,
            lastPurchaseAt: lastPurchaseAt,
            isSynced: isSynced,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<double> totalPurchases = const Value.absent(),
            Value<DateTime?> lastPurchaseAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            supabaseId: supabaseId,
            name: name,
            phone: phone,
            totalPurchases: totalPurchases,
            lastPurchaseAt: lastPurchaseAt,
            isSynced: isSynced,
            createdAt: createdAt,
          ),
        ));
}

class $$CustomersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get phone => $state.composableBuilder(
      column: $state.table.phone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalPurchases => $state.composableBuilder(
      column: $state.table.totalPurchases,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastPurchaseAt => $state.composableBuilder(
      column: $state.table.lastPurchaseAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CustomersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get phone => $state.composableBuilder(
      column: $state.table.phone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalPurchases => $state.composableBuilder(
      column: $state.table.totalPurchases,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastPurchaseAt => $state.composableBuilder(
      column: $state.table.lastPurchaseAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<String?> supabaseId,
  Value<String?> customerPhone,
  Value<String> customerName,
  Value<double> amount,
  Value<String?> note,
  Value<bool> isSynced,
  Value<DateTime> paidAt,
  Value<DateTime> createdAt,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<String?> supabaseId,
  Value<String?> customerPhone,
  Value<String> customerName,
  Value<double> amount,
  Value<String?> note,
  Value<bool> isSynced,
  Value<DateTime> paidAt,
  Value<DateTime> createdAt,
});

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PaymentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PaymentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> paidAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            supabaseId: supabaseId,
            customerPhone: customerPhone,
            customerName: customerName,
            amount: amount,
            note: note,
            isSynced: isSynced,
            paidAt: paidAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> paidAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            supabaseId: supabaseId,
            customerPhone: customerPhone,
            customerName: customerName,
            amount: amount,
            note: note,
            isSynced: isSynced,
            paidAt: paidAt,
            createdAt: createdAt,
          ),
        ));
}

class $$PaymentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get customerPhone => $state.composableBuilder(
      column: $state.table.customerPhone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get customerName => $state.composableBuilder(
      column: $state.table.customerName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get paidAt => $state.composableBuilder(
      column: $state.table.paidAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PaymentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get customerPhone => $state.composableBuilder(
      column: $state.table.customerPhone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get customerName => $state.composableBuilder(
      column: $state.table.customerName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get paidAt => $state.composableBuilder(
      column: $state.table.paidAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ShopProfilesTableCreateCompanionBuilder = ShopProfilesCompanion
    Function({
  Value<int> id,
  Value<String> shopName,
  Value<String?> shopAddress,
  Value<String?> shopPhone,
  Value<String?> shopGstNumber,
  Value<String?> shopEmail,
  Value<String?> logoPath,
  Value<String?> supabaseId,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});
typedef $$ShopProfilesTableUpdateCompanionBuilder = ShopProfilesCompanion
    Function({
  Value<int> id,
  Value<String> shopName,
  Value<String?> shopAddress,
  Value<String?> shopPhone,
  Value<String?> shopGstNumber,
  Value<String?> shopEmail,
  Value<String?> logoPath,
  Value<String?> supabaseId,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});

class $$ShopProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShopProfilesTable,
    ShopProfile,
    $$ShopProfilesTableFilterComposer,
    $$ShopProfilesTableOrderingComposer,
    $$ShopProfilesTableCreateCompanionBuilder,
    $$ShopProfilesTableUpdateCompanionBuilder> {
  $$ShopProfilesTableTableManager(_$AppDatabase db, $ShopProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ShopProfilesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ShopProfilesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> shopName = const Value.absent(),
            Value<String?> shopAddress = const Value.absent(),
            Value<String?> shopPhone = const Value.absent(),
            Value<String?> shopGstNumber = const Value.absent(),
            Value<String?> shopEmail = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ShopProfilesCompanion(
            id: id,
            shopName: shopName,
            shopAddress: shopAddress,
            shopPhone: shopPhone,
            shopGstNumber: shopGstNumber,
            shopEmail: shopEmail,
            logoPath: logoPath,
            supabaseId: supabaseId,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> shopName = const Value.absent(),
            Value<String?> shopAddress = const Value.absent(),
            Value<String?> shopPhone = const Value.absent(),
            Value<String?> shopGstNumber = const Value.absent(),
            Value<String?> shopEmail = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ShopProfilesCompanion.insert(
            id: id,
            shopName: shopName,
            shopAddress: shopAddress,
            shopPhone: shopPhone,
            shopGstNumber: shopGstNumber,
            shopEmail: shopEmail,
            logoPath: logoPath,
            supabaseId: supabaseId,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
        ));
}

class $$ShopProfilesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ShopProfilesTable> {
  $$ShopProfilesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shopName => $state.composableBuilder(
      column: $state.table.shopName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shopAddress => $state.composableBuilder(
      column: $state.table.shopAddress,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shopPhone => $state.composableBuilder(
      column: $state.table.shopPhone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shopGstNumber => $state.composableBuilder(
      column: $state.table.shopGstNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shopEmail => $state.composableBuilder(
      column: $state.table.shopEmail,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get logoPath => $state.composableBuilder(
      column: $state.table.logoPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ShopProfilesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ShopProfilesTable> {
  $$ShopProfilesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shopName => $state.composableBuilder(
      column: $state.table.shopName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shopAddress => $state.composableBuilder(
      column: $state.table.shopAddress,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shopPhone => $state.composableBuilder(
      column: $state.table.shopPhone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shopGstNumber => $state.composableBuilder(
      column: $state.table.shopGstNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shopEmail => $state.composableBuilder(
      column: $state.table.shopEmail,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get logoPath => $state.composableBuilder(
      column: $state.table.logoPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get supabaseId => $state.composableBuilder(
      column: $state.table.supabaseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$BillItemsTableTableManager get billItems =>
      $$BillItemsTableTableManager(_db, _db.billItems);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$ShopProfilesTableTableManager get shopProfiles =>
      $$ShopProfilesTableTableManager(_db, _db.shopProfiles);
}
