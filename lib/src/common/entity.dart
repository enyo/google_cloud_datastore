part of datastore.common;

class Entity {
  Datastore datastore;
  final Key key;
  Kind get kind => datastore.kindByName(key.kind);
  final PropertyMap _properties;
  
  /**
   * Create a new [Entity] against the given [datastore]
   * with the given [key] and, optionally, initial values
   * for the entity's properties.
   */
  Entity(Datastore datastore, Key key, [Map<String,dynamic> propertyInits = const {}]) :
    this.datastore = datastore,
    this.key = key,
    _properties = new PropertyMap(datastore.kindByName(key.kind), propertyInits);
  
  dynamic getProperty(String propertyName) {
    var prop = _properties[propertyName];
    if (prop == null) {
      throw new NoSuchPropertyError(this, propertyName);
    }
    return prop.value;
  }
  
  void setProperty(String propertyName, var value) {
    var prop = _properties[propertyName];
    if (prop == null) {
      throw new NoSuchPropertyError(this, propertyName);
    }
    prop.value = value;
  }
  
  schema.Entity _toSchemaEntity() {
    schema.Entity schemaEntity = new schema.Entity();
    schemaEntity.key = key._toSchemaKey();
    _properties.forEach((String name, _PropertyInstance prop) {
      var defn = kind.properties[name];
      schemaEntity.property.add(prop._toSchemaProperty(defn));
    });  
    return schemaEntity;
  }
  
  bool operator ==(Object other) => other is Entity && other.key == key;
  int get hashCode => key.hashCode;
  
  String toString() => "Entity($key)";
}

/**
 * The result of a lookup operation for an [Entity].
 */
class EntityResult<T extends Entity> {
  static const KEY_ONLY = 0;
  static const ENTITY_PRESENT = 1;
  
  /**
   * The looked up key
   */
  final Key key;
  /**
   * The entity found associated with the [:key:] in the datastore,
   * or `null` if no entity corresponding with the given key exists.
   */
  final T entity;
  
  bool get isKeyOnlyResult => resultType == KEY_ONLY;
  
  bool get isPresent => resultType == ENTITY_PRESENT;
  
  final resultType;
  
  EntityResult._(this.resultType, this.key, this.entity);
  
  factory EntityResult._fromSchemaEntityResult(
      Datastore datastore,
      schema.EntityResult entityResult, 
      schema.EntityResult_ResultType resultType) {
    if (resultType == schema.EntityResult_ResultType.KEY_ONLY) {
      var key = new Key._fromSchemaKey(entityResult.entity.key);
      return new EntityResult._(KEY_ONLY, key, null);
    }
    if (resultType == schema.EntityResult_ResultType.FULL) {
      var key = new Key._fromSchemaKey(entityResult.entity.key);
      var kind = datastore.kindByName(key.kind);
      var ent = kind._fromSchemaEntity(datastore, key, entityResult.entity);
      return new EntityResult._(ENTITY_PRESENT, key, ent);
    }
    //We don't support projections (yet).
    assert(false);
  }
}

class PropertyMap extends UnmodifiableMapMixin<String,_PropertyInstance> {
  final Kind kind;
  Map<String,_PropertyInstance> _entityProperties;
  
  PropertyMap(Kind kind, Map<String,dynamic> propertyInits) :
    this.kind = kind,
    _entityProperties = new Map.fromIterable(
        kind.properties.values,
        key: (prop) => prop.name,
        value: (Property prop) => prop.type.create(initialValue: propertyInits[prop.name])
    );
  
  @override
  _PropertyInstance operator [](String key) => _entityProperties[key];

  @override
  bool containsKey(String key) => _entityProperties.containsKey(key);

  @override
  bool containsValue(_PropertyInstance value) => _entityProperties.containsValue(value);

  @override
  void forEach(void f(String key, _PropertyInstance value)) {
    _entityProperties.forEach(f);
  }

  @override
  bool get isEmpty => _entityProperties.isEmpty;

  @override
  bool get isNotEmpty => _entityProperties.isNotEmpty;

  @override
  Iterable<String> get keys => _entityProperties.keys;

  @override
  int get length => _entityProperties.length;

  @override
  Iterable<_PropertyInstance> get values => _entityProperties.values;
}
