<?php

class Document{
  protected $fedora_item;
  protected $pid;
  
  public function __construct($fedora_item) {
    $this->fedora_item = $fedora_item;
    $this->pid = $fedora_item->pid;
  }

  public function create() {
    module_load_include('inc', 'fedora_repository', 'api/fedora_item');
    
    $conf = $_SESSION['conference'];
    $type = $_SESSION['document_type'];
    
    if ($conf) {
      $this->fedora_item->add_relationship('isMemberOfCollection', $conf);
    }
    
    $parent = new Fedora_Item($conf); // @TODO: validate
    $mxe = $parent->get_datastream_dissemination('MXE');
      
    $mxe_xml = new SimpleXMLElement($mxe);
    $mxe_xml->registerXPathNamespace('mxe', 'http://mx.dtic.dk/ns/mxe_draft');

    $ddf = $this->fedora_item->get_datastream_dissemination('DDF');
    $ddf_xml = new SimpleXMLElement($ddf);
    $ddf_xml->registerXPathNamespace('mxd', 'http://mx.forskningsdatabasen.dk/ns/mxd/');

    $this->createEvents($mxe_xml, $ddf_xml, $_SESSION['contribution']);
    
    if (isset($_SESSION['contribution'])) {
      //@TODO: need to update contribution if it is set
      $contribution = new Fedora_Item($_SESSION['contribution']);
      $mxe = $contribution->get_datastream_dissemination('MXE');
      $mxe_xml = new SimpleXMLElement($mxe);
      $mxe_xml->registerXPathNamespace('mxe', 'http://mx.dtic.dk/ns/mxe_draft');
      $parent = $contribution;
      unset($_SESSION['contribution']);
    }
    
    // Update conference/contribution if document is Program or Proceedings
    if (isset($type)) {
      
      if (!$mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->documents) {
        $mxe_xml->addChild('documents');
      }
      $doc = $mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->documents->addChild('document');
      $doc->addAttribute('id', $this->pid);
      $doc->addAttribute('role', $type); //@TODO: validate
      $doc->addAttribute('access', 'oa');
      
      $doc->addChild('description', ucfirst($type));

      $conf_pid = dtu_get_conference_url($conf);

      $doc->addChild('uri', $conf_pid . '/fedora/repository/' . $this->pid);
      $parent->modify_datastream_by_value($mxe_xml->asXML(), 'MXE', 'MXE', 'text/xml');

      switch ($type) {
        case 'paper':
          $this->fedora_item->add_relationship('hasModel', 'islandora:sp_strict_pdf', FEDORA_MODEL_URI);
          break;
        case 'video':
          $this->fedora_item->add_relationship('hasModel', 'islandora:sp_videoCModel', FEDORA_MODEL_URI);
          break;
        case 'slides':
          $this->fedora_item->add_relationship('hasModel', 'islandora:sp_strict_pdf', FEDORA_MODEL_URI);
          break;
      }
    }

    $this->updateDDF($ddf_xml, $type);

    unset($_SESSION['conference']);
    unset($_SESSION['document_type']);
  }
  
  private function createEvents($conf_mxe_xml, $ddf_xml, $contrib_pid = NULL) {
    $conf_event = $ddf_xml->addChild('event');
    $conf_event->addAttribute('event_role', 'ep');
    $conf_event->addChild('title');

    if (!empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->main)) {
      $conf_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->title->addChild('full', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->main);
    }
    if (!empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->short)) {
      $conf_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->title->addChild('acronym', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->short);
    }
    if (!empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->number)) {
      $conf_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->title->addChild('number', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->number);
    }

    if (!empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->start) || !empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->end)) {
      $conf_event->addChild('dates');
      $conf_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->dates->addChild('start', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->start);
      $conf_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->dates->addChild('end', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->end);
    }

    $place = '';
    if (!empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->city)) {
      $place .= (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->city;
    }
    if (!empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->country)) {
      $place .= ', ' . (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->country;
    }
    if (!empty($place)) {
      $conf_event->addChild('place', $place);
    }
    if (!empty($conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->uri)) {
      $conf_event->addChild('uri', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->uri);
    }
    $conf_event->addChild('id', (string) $conf_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->id);
    $conf_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->id->addAttribute('type', 'loc_eve');
    
    if (!is_null($contrib_pid)) {
      $contribution = new Fedora_Item($contrib_pid);
      
      $contrib_mxe = $contribution->get_datastream_dissemination('MXE');
      $contrib_mxe_xml = new SimpleXMLElement($contrib_mxe);

      // Add sub_event for track
      $track = $contrib_mxe_xml->xpath('//mxe:super_event[@event_type="tra"]');

      $track_node = $conf_event->addChild('sub_event');
      $track_node->addAttribute('event_type', 'tra');

      $track_node->addChild('title', (string) $track[0]->children('http://mx.dtic.dk/ns/mxe_draft')->title);
      $track_node->addChild('acronym', (string) $track[0]->children('http://mx.dtic.dk/ns/mxe_draft')->acronym);

      // Add sub_event for session
      $sess = $contrib_mxe_xml->xpath('//mxe:super_event[@event_type="ses"]');
      $sess_node = $conf_event->addChild('sub_event');
      $sess_node->addAttribute('event_type', 'ses');
      $sess_node->addChild('title', (string) $sess[0]->children('http://mx.dtic.dk/ns/mxe_draft')->title);
      $sess_node->addChild('acronym', (string) $sess[0]->children('http://mx.dtic.dk/ns/mxe_draft')->acronym);


      // Add event for contribution
      $cont_event = $ddf_xml->addChild('event');
      $cont_event->addAttribute('event_role', 'ep');
      $cont_event->addChild('title');
      $cont_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->title->addChild('full', (string) $contrib_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->title->original->main);
      $cont_event->addChild('dates');
      $cont_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->dates->addChild('start', (string) $contrib_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->start);  //@TODO: check date format
      $cont_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->dates->addChild('end', (string) $contrib_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->date->end);

      $place = '';
      if (!empty($contrib_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->city)) {
        $place .= (string) $contrib_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->city;
      }

      if (!empty($contrib_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->country)) {
        $place .= $place . ', ' . (string) $contrib_mxe_xml->children('http://mx.dtic.dk/ns/mxe_draft')->location->country;
      }
      $cont_event->addChild('place', $place);

      $conf_url = dtu_get_conference_url($conf_mxe_xml->attributes()->rec_id);

      $cont_event->addChild('uri', $conf_url . '/fedora/repository/' . $this->pid);  //@TODO: get properly
      $cont_event->addChild('id', $this->pid);
      $cont_event->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->id->addAttribute('type', 'loc_eve');

    }
    
    $this->fedora_item->modify_datastream_by_value($ddf_xml->asXML(), 'DDF', 'DDF', 'text/xml');
  }

  public function updateDDF($ddf_xml, $type) {
    // DDF attributes
    $ddf_xml->addAttribute('format_verion', '1.3.0');
    $ddf_xml->addAttribute('doc_lang', 'eng');
    $ddf_xml->addAttribute('doc_level', 'und');
    $ddf_xml->addAttribute('doc_review', 'und');

    if ($type == 'paper') {
      $doc_type = 'dcp';
    }
    else {
      $doc_type = 'dct';
    }

    $ddf_xml->addAttribute('doc_type', $doc_type);
    $date = (string) $ddf_xml->children('http://mx.forskningsdatabasen.dk/ns/mxd/')->event[0]->dates->start;
    $explode_date = explode('-', $date);
    $year = $explode_date[2];

    $ddf_xml->addAttribute('doc_year', $year);
    $ddf_xml->addAttribute('rec_id', $this->pid);
    $ddf_xml->addAttribute('rec_source', 'dtu_conferences');
    $ddf_xml->addAttribute('rec_status', 'c');


    // <document> node

    // check for obj
    //$datastreams = $this->fedora_item->get_datastreams_list_as_array();
    $obj_info = $this->fedora_item->get_datastream_info('OBJ');

    if (!empty($obj_info)) {
      $publication = $ddf_xml->addChild('publication');
      $publication->addChild('inetpub');
      $publication->inetpub->addChild('title', 'Published in DTU Conferences (by DTU Library)');
      $publication->inetpub->addChild('uri', 'http://'); //@TODO: proper url for parent contrib
      $publication->inetpub->uri->addAttribute('access', 'oa');

      $publication->addChild('digital_object');
      $publication->digital_object->addAttribute('id', '1');
      $publication->digital_object->addAttribute('role', 'pub');
      $publication->digital_object->addAttribute('access', 'oa');
      $publication->digital_object->addAttribute('license', 'cc_by_nd_3.0'); //@TODO: dynamic
      $publication->digital_object->addChild('title', 'Talk ' . ucfirst($type));

      $publication->digital_object->addChild('file');
      $publication->digital_object->file->addAttribute('size', $obj_info->datastream->size);
      $publication->digital_object->file->addAttribute('mime_type', $obj_info->datastream->MIMEType);

      $timestamp = strtotime($obj_info->datastream->createDate);
      $publication->digital_object->file->addAttribute('timestamp', date('Y-m-d', $timestamp));
      //$publication->digital_object->file->addAttribute('filename', ) //@TODO: do we have this
      $publication->digital_object->addChild('uri', 'http://'); //@TODO: proper url for datastream
      $publication->digital_object->uri->addAttribute('access', 'oa');

    }

    $this->fedora_item->modify_datastream_by_value($ddf_xml->asXML(), 'DDF', 'DDF', 'text/xml');
  }
}