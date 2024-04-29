require 'tk'
require 'faker'
require 'csv'
require 'json'
require 'builder'

class DummyDataGenerator
  attr_accessor :num_records

  def initialize
    @num_records = 1
    @output_format = :sql

    @surnames = {
      'Apellido1' => ['Pinol', 'Romez', 'Artí', 'Meza'],
      'Apellido2' => ['Intah', 'Json', 'oli', 'Gon']
    }

    @format_buttons = {
      :sql => TkButton.new { text 'Exportar a SQL'; command { @output_format = :sql } },
      :csv => TkButton.new { text 'Exportar a CSV'; command { @output_format = :csv } },
      :xml => TkButton.new { text 'Exportar a XML'; command { @output_format = :xml } },
      :json => TkButton.new { text 'Exportar a JSON'; command { @output_format = :json } }
    }

    build_ui
  end

  def build_ui
    root = TkRoot.new { title "Generador de Dummy Data" }
    TkLabel.new(root) { text 'Número de registros:'; background 'lightblue'; foreground 'white' }.pack
    @num_records_entry = TkEntry.new(root) { background 'lightgray' }.pack
    TkButton.new(root) { text 'Generar y Exportar'; command { generate_data } }.pack

    @format_buttons.each do |format, button|
      button.pack
    end
  end

  def generate_data
    num_records_str = @num_records_entry.get
    return if num_records_str.empty?

    @num_records = num_records_str.to_i

    case @output_format
    when :sql
      generate_sql()
    when :csv
      generate_csv()
    when :xml
      generate_xml()
    when :json
      generate_json()
    end
  end

  def generate_sql
    File.open("dummy_data.sql", "w") do |file|
      file.puts "INSERT INTO sistema_escolar (Matricula, Apellido1, Apellido2, Nombres, Correo, Fecha_Nacimiento) VALUES"
      @num_records.times do |i|
        matricula = Faker::Number.unique.number(digits: 8)
        apellido1 = @surnames['Apellido1'].sample
        apellido2 = @surnames['Apellido2'].sample
        nombres = Faker::Name.unique.name
        correo = Faker::Internet.unique.email
        fecha_nacimiento = Faker::Date.birthday(min_age: 5, max_age: 18).strftime('%Y-%m-%d')

        values = "('#{matricula}', '#{apellido1}', '#{apellido2}', '#{nombres}', '#{correo}', '#{fecha_nacimiento}')"
        values += "," unless i == @num_records - 1
        file.puts values
      end
    end
  end

  def generate_csv
    CSV.open("dummy_data.csv", "w") do |csv|
      csv << ["Matricula", "Apellido1", "Apellido2", "Nombres", "Correo", "Fecha_Nacimiento"]
      @num_records.times do
        matricula = Faker::Number.unique.number(digits: 8)
        apellido1 = @surnames['Apellido1'].sample
        apellido2 = @surnames['Apellido2'].sample
        nombres = Faker::Name.unique.name
        correo = Faker::Internet.unique.email
        fecha_nacimiento = Faker::Date.birthday(min_age: 5, max_age: 18)

        csv << [matricula, apellido1, apellido2, nombres, correo, fecha_nacimiento]
      end
    end
  end

  def generate_xml
    xml = Builder::XmlMarkup.new(indent: 2)
    File.open("dummy_data.xml", "w") do |file|
      file.puts xml.sistema_escolar {
        @num_records.times do
          matricula = Faker::Number.unique.number(digits: 8)
          apellido1 = @surnames['Apellido1'].sample
          apellido2 = @surnames['Apellido2'].sample
          nombres = Faker::Name.unique.name
          correo = Faker::Internet.unique.email
          fecha_nacimiento = Faker::Date.birthday(min_age: 5, max_age: 18).strftime('%Y-%m-%d')

          file.puts xml.alumno {
            xml.Matricula matricula
            xml.Apellido1 apellido1
            xml.Apellido2 apellido2
            xml.Nombres nombres
            xml.Correo correo
            xml.Fecha_Nacimiento fecha_nacimiento
          }
        end
      }
    end
  end

  def generate_json
    data = []
    @num_records.times do
      matricula = Faker::Number.unique.number(digits: 8)
      apellido1 = @surnames['Apellido1'].sample
      apellido2 = @surnames['Apellido2'].sample
      nombres = Faker::Name.unique.name
      correo = Faker::Internet.unique.email
      fecha_nacimiento = Faker::Date.birthday(min_age: 5, max_age: 18)

      data << {
        "Matricula" => matricula,
        "Apellido1" => apellido1,
        "Apellido2" => apellido2,
        "Nombres" => nombres,
        "Correo" => correo,
        "Fecha_Nacimiento" => fecha_nacimiento
      }
    end

    File.open("dummy_data.json", "w") do |file|
      file.puts JSON.pretty_generate(data)
    end
  end
end

DummyDataGenerator.new
Tk.mainloop
