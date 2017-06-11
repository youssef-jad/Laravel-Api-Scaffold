=begin
Author : Youssef Jad
=end
begin
  require 'fileutils'
rescue Exception => e
  puts e
end

class Generator
  @@columns
  @@table_name
  @@orignal_table_name

  def initialize columns, table_name
    @@columns = columns
    @@table_name = table_name
    @@orignal_table_name = table_name
    titlized
  end

  def titlized
    nameStr = @@table_name
    @@table_name = nameStr.split(/ |\_/).map(&:capitalize).join("")
  end

  def makeDirectories
    if !File.exist? "Modules"
      Dir.mkdir("Modules" , 0775)
    end
    input = "-----Generating #{@@table_name}-----\n"
    input.each_char { |c|
      print c
      sleep(0.1)
    }
    sleep 2
    puts "\e[H\e[2J"

    directory = @@table_name
    if !File.exist? directory
      File.expand_path(".", Dir.pwd)
      Dir.mkdir("Modules/" + @@table_name, 0775)
      File.new("Modules/" + @@table_name + "/route.php", "w")
      File.new("Modules/" + @@table_name + "/install.txt", "w")

      Dir.mkdir("Modules/" + @@table_name + "/Models", 0775)
      File.new("Modules/" + @@table_name + "/Models/" + "#{@@table_name}.php", "w")

      Dir.mkdir("Modules/" + @@table_name + "/Controllers", 0775)
      File.new("Modules/" + @@table_name + "/Controllers/" + "#{@@table_name}Controller.php", "w")
    end
    writeRoute
    writeController
    writeModel
    writeInstall
    finish
  end


  def writeRoute
    File.open("Modules/" + @@table_name + "/route.php", File::RDWR|File::CREAT, 0644) { |file|
      file.flock(File::LOCK_EX)
      routeBloc = <<~HEREDOC
        <?php

        /*
        |--------------------------------------------------------------------------
        | Application Routes
        |--------------------------------------------------------------------------
        |
        | Here is where you can register all of the routes for an application.
        | It's a breeze. Simply tell Laravel the URIs it should respond to
        | and give it the controller to call when that URI is requested.
        |
        */

        Route::resources('/', '#{@@table_name}Controller');


      HEREDOC

      file.write("#{routeBloc}\n")
      file.flush
      file.truncate(file.pos)
    }
  end


  def writeController
    File.open("Modules/" + @@table_name + "/Controllers/" + "#{@@table_name}Controller.php", File::RDWR|File::CREAT, 0644) { |file|
      file.flock(File::LOCK_EX)
      file.write("#{writeControllerIndex}\n")
      file.write("#{writeControllerShow}\n")
      file.write("#{writeControllerStore}\n")
      file.write("#{writeControllerUpdate}\n")
      file.write("#{writeControllerDelete}\n")
      file.flush
      file.truncate(file.pos)
    }
  end


  def writeControllerIndex

    block = <<~HEREDOC
      <?php

      namespace App\\Http\\Controllers;

      use App\\Models\\#{@@table_name};
      use Illuminate\\Http\\Request;
      use App\\Http\\Requests;
      use Illuminate\\Support\\Facades\\Input;
      use Illuminate\\Support\\Facades\\Validator;

      class #{@@table_name}Controller extends Controller
      {
          public function __construct(){

          }

          public function index()
          {
              $#{@@table_name}Obj = #{@@table_name}::all();

              foreach ($#{@@table_name}Obj as $key => $value) {
                  $data['data'][$key] = new \\stdClass;
    HEREDOC

    @@columns.each do |col|
      block += <<-TEXT
            $data['data'][$key]->#{col['Field']} = $value['#{col['Field']}'];
      TEXT
    end

    block += <<~HEREDOC
          }
              $data['status'] = new \\stdClass;
              $data['status']->code = 200;
              $data['status']->status = true;
              return response()->json($data);
          }

    HEREDOC
    return block

  end


  def writeControllerShow
    block = <<~HEREDOC
      public function show($id)
      {
          $id = (int) $id;
          $#{@@table_name}Obj = #{@@table_name}::find($id);
          if($#{@@table_name}Obj !== null){
              $data['data'] = new \\stdClass();
    HEREDOC

    @@columns.each do |col|
      block += <<-TEXT
        $data['data']->#{col['Field']} = $#{@@table_name}Obj['#{col['Field']}'];
      TEXT
    end

    block += <<~HEREDOC
            $data['status'] = new \\stdClass;
            $data['status']->status = true;
            $data['status']->code = 200;
         }else{
            $data['status'] = new \\stdClass;
            $data['status']->status = false;
            $data['status']->code = 204;
         }
          return response()->json($data);

       }
    HEREDOC
    return block
  end


  def writeControllerStore

    block = <<~HEREDOC
      public function store(){

        $input = Input::all();
        $rules = [];
        $validator = \\Validator::make($input, $rules);
        if ($validator->fails()) {
          $data['status'] = new \\stdClass;
          $data['status']->status = false;
          $data['status']->code = 400;
          $data['status']->message = $validator->messages()->first();
        throw new \Exception($data['status']->message, $data['status']->code);
        }else{
            $#{@@table_name}Obj = new #{@@table_name}();
    HEREDOC

    @@columns.each do |col|

      if(col['Field'] != @@columns.first['Field'])
        block += <<-TEXT
        $#{@@table_name}Obj->#{col['Field']} = $input['#{col['Field']}'];
        TEXT
      end

    end

    block += <<~HEREDOC
      if($#{@@table_name}Obj->save()){
        $data['status'] = new \\stdClass;
        $data['status']->code = 200;
        $data['status']->status = true;
        $data['status']->message = "Created";
        return response()->json($data);
      }else{
        $data['status'] = new \\stdClass;
        $data['status']->code = 200;
        $data['status']->status = false;
        $data['status']->message = "Error While Creating Object";
        throw new \Exception($data['status']->message, $data['status']->code);
          }
        }
      }
    HEREDOC

    return block
  end


  def writeControllerUpdate

    block = <<~HEREDOC
      public function update($id){

        $input = Input::all();
        $rules = [];
        $validator = \\Validator::make($input, $rules);
        if ($validator->fails()) {
          $data['status'] = new \\stdClass;
          $data['status']->status = false;
          $data['status']->code = 400;
          $data['status']->message = $validator->messages()->first();
        throw new \Exception($data['status']->message, $data['status']->code);
        }else{
          $#{@@table_name}Obj = #{@@table_name}::find($id);
    HEREDOC

    @@columns.each do |col|
      if(col['Field'] != @@columns.first['Field'])
        block += <<-TEXT
        $#{@@table_name}Obj->#{col['Field']} = $input['#{col['Field']}'];
        TEXT
      end

    end

    block += <<~HEREDOC
      if($#{@@table_name}Obj->save()){
        $data['status'] = new \\stdClass;
        $data['status']->code = 200;
        $data['status']->status = true;
        $data['status']->message = "Updated";
        return response()->json($data);
      }else{
        $data['status'] = new \\stdClass;
        $data['status']->code = 200;
        $data['status']->status = false;
        $data['status']->message = "Error While Creating Object";
        throw new \Exception($data['status']->message, $data['status']->code);
          }
        }
      }
    HEREDOC

    return block

  end


  def writeControllerDelete

    block = <<~HEREDOC
      public function delete($id){
        $id = (int) $id;
        $#{@@table_name}Obj = #{@@table_name}::find($id);
        $#{@@table_name}Obj->delete();
        $data['status'] = new \\stdClass;
        $data['status']->code = 200;
        $data['status']->status = true;
        $data['status']->message = "Deleted";
        return response()->json($data);
  } 
}
    HEREDOC

    return block
  end


  def writeModel

    block = <<~HEREDOC
      <?php

      namespace App\\Models;

      use Illuminate\\Database\\Eloquent\\Model;

      class #{@@table_name} extends Model {
          protected $table = '#{@@orignal_table_name}';
          // Disable created_at
          public $timestamps = false;

          protected $primaryKey = '#{@@columns.first['Field']}';
      }
    HEREDOC

    File.open("Modules/" + @@table_name + "/Models/" + "#{@@table_name}.php", File::RDWR|File::CREAT, 0644) { |file|
      file.flock(File::LOCK_EX)
      file.write("#{block}\n")
      file.flush
      file.truncate(file.pos)
    }

  end

  def writeInstall
    block = <<~HEREDOC
    1 - Make Folder in app folder and rename it to Modules
    2 - Add "app/Modules" To composer.json file under autoload object
    3 - add The Toute File to app/Providers/RouteServiceProvider.php "require app_path('Modules/#{@@table_name}/routes.php')"

    You May Use The Generated File in any way you like

    Thanks

    Youssef Gad
    HEREDOC

    File.open("Modules/" + @@table_name + "/install.txt", File::RDWR|File::CREAT, 0644) { |file|
      file.flock(File::LOCK_EX)
      file.write("#{block}\n")
      file.flush
      file.truncate(file.pos)
    }
  end

  def finish
    block = <<~HEREDOC
    Laravel #{@@table_name.red} Module Successfully Created :

    1 - Make Folder in app folder and rename it to Modules
    2 - Add "app/Modules" To composer.json file under autoload object
    3 - add The Toute File to app/Providers/RouteServiceProvider.php "#{"require app_path('Modules/#{@@table_name}/routes.php')".red}"
    You May Use The Generated File in any way you like \n
    HEREDOC
    puts block.yellow
  end

end