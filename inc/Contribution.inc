<?php

class Contribution {
  protected $fedora_item;
  protected $pid;
  
  public function __construct($fedora_item) {
    $this->fedora_item = $fedora_item;
    $this->pid = $fedora_item->pid;
  }
  
  public function create() {
    module_load_include('inc', 'fedora_repository', 'api/fedora_item');
    
    $container_collection = new Fedora_Item(arg(2));
    $rels_ext = $container_collection->get_rdf_relationships();
    $conf_pid = $rels_ext['isMemberOfCollection'][0];
    
    if ($conf_pid) {
      $this->fedora_item->add_relationship('isMemberOfCollection', $conf_pid);
    }
    
    // Update <super_event/> of conference
    $conf_object = new Fedora_Item($conf_pid);
    $conf_mxe = $conf_object->get_datastream_dissemination('MXE');
    
    $cont_mxe = $this->fedora_item->get_datastream_dissemination('MXE');
    
    $conf_mxe_xml = new SimpleXMLElement($conf_mxe);
    $conf_mxe_xml->registerXPathNamespace('mxe', 'http://mx.dtic.dk/ns/mxe_draft');

    $cont_mxe_xml = new SimpleXMLElement($cont_mxe);
    $cont_mxe_xml->registerXPathNamespace('mxe', 'http://mx.dtic.dk/ns/mxe_draft');

    $this->updateMXE($conf_mxe_xml, $cont_mxe_xml, $conf_pid);

    $modified = dtu_mxe_tidy(&$cont_mxe_xml);
    if ($modified) {
      $this->fedora_item->modify_datastream_by_value($cont_mxe_xml->asXML(), 'MXE', 'MXE', 'text/xml');
    }
  }

  public function update() {
    module_load_include('inc', 'fedora_repository', 'api/fedora_item');
    // update Document <event/>

    $cont_mxe = $this->fedora_item->get_datastream_dissemination('MXE');
    $cont_mxe_xml = new SimpleXMLElement($cont_mxe);
    $cont_mxe_xml->registerXPathNamespace('mxe', 'http://mx.dtic.dk/ns/mxe_draft');

    $document_nodes = $cont_mxe_xml->xpath('//mxe:documents/mxe:document');
    foreach ($document_nodes AS $document_node) {
      $doc_id = (string) $document_node->attributes()->id;
      $document = new Fedora_Item($doc_id);

      $doc_ddf = $document->get_datastream_dissemination('DDF');
      $doc_ddf_xml = new SimpleXMLElement($doc_ddf);
      $doc_ddf_xml->registerXPathNamespace('mxd', 'http://mx.forskningsdatabasen.dk/ns/mxd/');


      $contrib_event = $doc_ddf_xml->xpath('//mxd:event/mxd:id[text()="' . $this->pid . '"]/..');

      $contrib_event[0]->title->full = (string) $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->main;
      $contrib_event[0]->dates->start = (string) $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->start;
      $contrib_event[0]->dates->end = (string) $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->end;

      $place = '';
      if (!empty($cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->city)) {
        $place .= (string) $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->city;
      }
      if (!empty($cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->country)) {
        $place .= ', ' . (string) $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->country;
      }
      $contrib_event[0]->place = $place;
      $contrib_event[0]->uri = $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->uri;

      $document->modify_datastream_by_value($doc_ddf_xml->asXML(), 'DDF', 'DDF', 'text/xml');
    }

    $modified = dtu_mxe_tidy(&$cont_mxe_xml);
    if ($modified) {
      $this->fedora_item->modify_datastream_by_value($cont_mxe_xml->asXML(), 'MXE', 'MXE', 'text/xml');
    }
  }

  function updateMXE($conf_mxe_xml, $cont_mxe_xml, $conf_pid) {
    $super_event = $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->super_events->addChild('super_event');
    $super_event->addAttribute('event_type', 'conference');
    $super_event->addAttribute('id', $conf_pid);

    $super_event->addChild('title');
    $super_event->children('http://mx.dtic.dk/ns/mxe_draft')->title->addChild('main', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->main);
    $super_event->children('http://mx.dtic.dk/ns/mxe_draft')->title->addChild('short', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->short);

    //@TODO: check if conf elements have a value before inserting
    //@TODO: transform and update DC?
    $super_event->addChild('organisation', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->venue);
    $super_event->addChild('uri', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->uri);

    $cont_mxe_xml->addAttribute('format_version', '0.1.1');
    $cont_mxe_xml->addAttribute('eve_lang', 'eng');
    $cont_mxe_xml->addAttribute('eve_level', 'und');
    $cont_mxe_xml->addAttribute('eve_type', 'ecoco');
    $cont_mxe_xml->addAttribute('eve_year', (string) $cont_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->year);
    $cont_mxe_xml->addAttribute('rec_id', $this->pid);
    $cont_mxe_xml->addAttribute('rec_source', 'dtu_conferences');
    $cont_mxe_xml->addAttribute('rec_status', 'c');

    $this->fedora_item->modify_datastream_by_value($cont_mxe_xml->asXML(), 'MXE', 'MXE', 'text/xml');
  }
}