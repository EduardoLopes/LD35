package objects;

class ObjectPool<T> {

  public var free:List<T>;
  public var busy:List<T>;

  var create : Void -> T;

  public function new (create_callback:Void -> T){

    free = new List();
    busy = new List();

    create = create_callback;

  }

  public function get() : T{

    var obj = free.pop();

    if(obj == null){
      free.add(create());

      obj = free.pop();
    }

    busy.add(obj);

    return obj;

  }

}