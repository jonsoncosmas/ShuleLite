<?php
declare(strict_types=1);
function registry_xml(string $xml): SimpleXMLElement
{
    $previous = libxml_use_internal_errors(true);
    try { $parsed = simplexml_load_string($xml, SimpleXMLElement::class, LIBXML_NONET | LIBXML_NOBLANKS); }
    finally { libxml_clear_errors(); libxml_use_internal_errors($previous); }
    if (!$parsed) throw new DomainException('The Excel workbook contains an invalid worksheet.');
    return $parsed;
}
function registry_cell_text(SimpleXMLElement $node, string $namespace): string
{
    $text='';
    foreach($node->children($namespace) as $child){$text.=$child->getName()==='t'?(string)$child:registry_cell_text($child,$namespace);}
    return $text;
}
function read_registry_xlsx(string $tmpPath): array
{
    $copy = sys_get_temp_dir().DIRECTORY_SEPARATOR.'shulelite-registry-'.bin2hex(random_bytes(12)).'.xlsx';
    if (!copy($tmpPath, $copy)) throw new DomainException('The workbook could not be read. Try saving it as .xlsx and uploading it again.');
    try {
        $zip = new PharData($copy);
        $get = static function(string $path) use ($zip): ?string { try { return isset($zip[$path]) ? $zip[$path]->getContent() : null; } catch (Throwable $ignored) { return null; } };
        $sheetPath = 'xl/worksheets/sheet1.xml';
        $workbookText = $get('xl/workbook.xml'); $relsText = $get('xl/_rels/workbook.xml.rels');
        if ($workbookText && $relsText) {
            $workbook = registry_xml($workbookText); $rels = registry_xml($relsText);
            $workbook->registerXPathNamespace('x','http://schemas.openxmlformats.org/spreadsheetml/2006/main');
            $workbook->registerXPathNamespace('r','http://schemas.openxmlformats.org/officeDocument/2006/relationships');
            $sheets = $workbook->xpath('//x:sheets/x:sheet');
            $first = $sheets[0] ?? null;
            if ($first) {
                $attrs = $first->attributes('http://schemas.openxmlformats.org/officeDocument/2006/relationships');
                $relationshipId = (string)($attrs['id'] ?? '');
                foreach ($rels->children('http://schemas.openxmlformats.org/package/2006/relationships')->Relationship as $relationship) {
                    $relationshipAttributes=$relationship->attributes();
                    if ((string)($relationshipAttributes['Id']??'') === $relationshipId) {
                        $target = str_replace('\\','/',(string)($relationshipAttributes['Target']??''));
                        if (str_starts_with($target,'/')) $sheetPath = ltrim($target,'/');
                        else $sheetPath = 'xl/'.ltrim($target,'/');
                        break;
                    }
                }
            }
        }
        if (str_contains($sheetPath,'..') || !$sheetXml = $get($sheetPath)) throw new DomainException('The workbook has no readable first worksheet.');
        $shared=[]; if($sharedXml=$get('xl/sharedStrings.xml')) { $sharedRoot=registry_xml($sharedXml);$main=$sharedRoot->children('http://schemas.openxmlformats.org/spreadsheetml/2006/main');foreach($main->si as $item)$shared[]=registry_cell_text($item,'http://schemas.openxmlformats.org/spreadsheetml/2006/main'); }
        $sheet=registry_xml($sheetXml);$ns='http://schemas.openxmlformats.org/spreadsheetml/2006/main';$sheet->registerXPathNamespace('x',$ns);$rows=[];
        foreach($sheet->xpath('//x:sheetData/x:row')?:[] as $row){$cells=[];foreach($row->children($ns)->c as $cell){$attributes=$cell->attributes();$address=(string)($attributes['r']??'');if(!preg_match('/^([A-Z]+)/',$address,$match))continue;$column=0;foreach(str_split($match[1]) as $letter)$column=$column*26+(ord($letter)-64);$type=(string)($attributes['t']??'');$cellChildren=$cell->children($ns);$value=(string)$cellChildren->v;if($type==='s')$value=$shared[(int)$value]??'';elseif($type==='inlineStr'&&isset($cellChildren->is[0]))$value=registry_cell_text($cellChildren->is[0],$ns);$cells[$column-1]=$value;}if($cells){ksort($cells);$last=max(array_keys($cells));$rows[]=array_map(static fn($i)=>$cells[$i]??'',range(0,$last));}if(count($rows)>502)throw new DomainException('The workbook has too many rows. Import up to 500 class rows at a time.');}
        return $rows;
    } catch (DomainException $error) { throw $error; }
    catch (Throwable $error) { throw new DomainException('We could not open this Excel workbook. Save it as a standard .xlsx file and try again.'); }
    finally { if(is_file($copy))@unlink($copy); }
}
function read_registry_csv(string $tmpPath): array
{
    $handle=fopen($tmpPath,'rb');if(!$handle)throw new DomainException('The CSV file could not be read.');$rows=[];
    try { while(($row=fgetcsv($handle))!==false){if(isset($row[0]))$row[0]=preg_replace('/^\xEF\xBB\xBF/','',(string)$row[0]);$rows[]=$row;if(count($rows)>502)throw new DomainException('The file has too many rows. Import up to 500 class rows at a time.');} }
    finally { fclose($handle); }
    return $rows;
}
function parse_class_registry_upload(array $file): array
{
    if(($file['error']??UPLOAD_ERR_NO_FILE)!==UPLOAD_ERR_OK)throw new DomainException('Choose an Excel .xlsx or CSV file to import.');
    if((int)($file['size']??0)>10*1024*1024)throw new DomainException('The file is too large. Keep the upload below 10 MB.');
    $extension=strtolower(pathinfo((string)($file['name']??''),PATHINFO_EXTENSION));$rows=$extension==='xlsx'?read_registry_xlsx((string)$file['tmp_name']):($extension==='csv'?read_registry_csv((string)$file['tmp_name']):throw new DomainException('Upload a .xlsx Excel workbook or a .csv file exported from Excel.'));
    if(count($rows)<2)throw new DomainException('The file needs a header row and at least one class row.');
    $headers=array_map(static function($header){$header=strtolower(trim((string)$header));return preg_replace('/[^a-z]/','',$header);},$rows[0]);$map=[];foreach($headers as $index=>$header){if(in_array($header,['class','classname'],true))$map['class']=$index;elseif(in_array($header,['stream','streams'],true))$map['streams']=$index;elseif(in_array($header,['subject','subjects'],true))$map['subjects']=$index;}
    if(!isset($map['class'],$map['streams'],$map['subjects']))throw new DomainException('Use these three column headings: Class, Streams, and Subjects().');
    $registry=[];$dataRows=0;foreach(array_slice($rows,1) as $row){$class=trim((string)($row[$map['class']]??''));$streams=trim((string)($row[$map['streams']]??''));$subjects=trim((string)($row[$map['subjects']]??''));if($class===''&&$streams===''&&$subjects==='')continue;if($class===''||strlen($class)>80||strlen($streams)>2000||strlen($subjects)>3000)throw new DomainException('Each populated row needs a class name (up to 80 characters); stream and subject lists must fit within their cell limits.');$key=mb_strtolower($class);if(!isset($registry[$key]))$registry[$key]=['name'=>$class,'streams'=>[],'subjects'=>[]];foreach([['streams',$streams,80],['subjects',$subjects,100]] as [$field,$list,$limit]){foreach(preg_split('/[,;|\n\r]+/',$list)?:[] as $item){$item=trim($item);if($item==='')continue;if(mb_strlen($item)>$limit)throw new DomainException(ucfirst(rtrim($field,'s')).' names must be '.$limit.' characters or fewer.');$registry[$key][$field][mb_strtolower($item)]=$item;}}$dataRows++;if($dataRows>500)throw new DomainException('Import up to 500 class rows at a time.');}
    if(!$registry)throw new DomainException('No class rows were found in this file.');return array_values($registry);
}

