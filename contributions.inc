<?php

function dtu_contribution_list($pid) {
  module_load_include('inc', 'fedora_repository', 'api/fedora_item');
  
  $contributions = dtu_get_contributions($pid);
  
  $header = array('', t('Title'), t('Presenter'), t('Track'), t('Session'), '', t('Paper'), t('Slides'), t('Video'));
  $rows = array();
  
  foreach ($contributions AS $contribution) {
    $item = new Fedora_Item($contribution['pid']);
    
    $rels_ext = $item->get_rdf_relationships();
    $conf_pid = $rels_ext['fedora:isMemberOfCollection'][1];
    
    $mxe = $item->get_datastream_dissemination('MXE');
    $mxe_xml = simplexml_load_string($mxe);
    
    $first_name = (string) $mxe_xml->person->name->first;
    $last_name = (string) $mxe_xml->person->name->last;
    $name = $first_name . ' ' . $last_name;
    
    $track = $mxe_xml->xpath('//super_events/super_event[@event_type="tra"]/title');
    $track = (string) $track[0];
    
    $session = $mxe_xml->xpath('//super_events/super_event[@event_type="ses"]/title');
    $session = (string) $session[0];
    
    $edit_link = l(t('Edit'), 'fedora/repository/' . $contribution['pid'], array('fragment' => 'tabset-1-tab-2'));
    $delete_link = l(t('Delete'), 'admin/contribution/' . $contribution['pid'] . '/delete');
    
    $obj_link = l($item->objectProfile->objLabel, 'fedora/repository/' . $contribution['pid']);
    
    $paper = $mxe_xml->xpath('//documents/document[@role="paper"]');
    if ($paper) {
      $paper_link = l(t('Edit'), 'fedora/repository/' . (string)$paper[0]->attributes()->id, array('fragment' => 'tabset-1-tab-2'));
    }
    else {
      $paper_link = l(t('Add'), 'admin/conference/' . $conf_pid . '/contribution/' . $contribution['pid'] . '/document/paper');
    }
    
    $slides = $mxe_xml->xpath('//documents/document[@role="slides"]');
    if ($slides) {
      $slides_link = l(t('Edit'), 'fedora/repository/' . (string)$slides[0]->attributes()->id, array('fragment' => 'tabset-1-tab-2'));
    }
    else {
      $slides_link = l(t('Add'), 'admin/conference/' . $conf_pid . '/contribution/' . $contribution['pid'] . '/document/slides');
    }
    
    $video = $mxe_xml->xpath('//documents/document[@role="video"]');
    if ($video) {
      $video_link = l(t('Edit'), 'fedora/repository/' . (string)$video[0]->attributes()->id, array('fragment' => 'tabset-1-tab-2'));
    }
    else {
      $video_link = l(t('Add'), 'admin/conference/' . $conf_pid . '/contribution/' . $contribution['pid'] . '/document/video');
    }
    
    $rows[] = array('', $obj_link, $name, $track, $session, $edit_link . ' | ' . $delete_link, $paper_link, $slides_link, $video_link);
  }
  
  $contributions_table = theme('table', $header, $rows);
  
  $contribution_collection_pid = dtu_get_contribution_collection($pid);
  $add_contribution = l(t('Add contribution'), 'fedora/repository/' . $contribution_collection_pid, array('fragment' => 'add-tab', 'query' => array('conf' => $pid)));
  
  return theme('dtu_contribution_admin_list', $contributions_table, $add_contribution);
}

function dtu_contribution_delete_form($form_state, $pid) {
  
}

function dtu_contribution_delete_form_submit($form, &$form_state) {
  
}

function dtu_get_contribution_collection($pid) {
  module_load_include('inc', 'fedora_repository', 'api/fedora_utils');
  $query_string = "select \$object \$title from <#ri>
    where \$object <dc:title> \$title
    and \$object <fedora-model:state> <info:fedora/fedora-system:def/model#Active>
    and \$object <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/$pid>
    and \$object <info:fedora/fedora-system:def/model#hasModel> <info:fedora/islandora:collectionCModel>
    order by \$object";
    
  $query_string = urlencode($query_string);

  $url = variable_get('fedora_repository_url', 'http://localhost:8080/fedora/risearch');
  $url .= "?type=tuples&flush=TRUE&format=Sparql&lang=itql&stream=on&query=". $query_string;
  $content = do_curl($url);
  
  $results = simplexml_load_string($content);
  
  $object_info = array();
  foreach ($results->results->result AS $result) {
    $pid = (string) $result->object['uri'][0];
    $pid = preg_replace('/^info:fedora\//', '', $pid);
    return $pid;
  }
}

function dtu_contribution_document_form_redirect($conf_pid, $con_pid, $document) {
  module_load_include('inc', 'fedora_repository', 'api/fedora_utils');
  $query_string = "select \$object from <#ri>
    where \$object <fedora-model:state> <info:fedora/fedora-system:def/model#Active>
    and \$object <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/$conf_pid>
    and \$object <info:fedora/fedora-system:def/relations-external#documentCollection> <info:fedora/$conf_pid>
    and \$object <info:fedora/fedora-system:def/model#hasModel> <info:fedora/islandora:collectionCModel>
    order by \$object";
    
  $query_string = urlencode($query_string);

  $url = variable_get('fedora_repository_url', 'http://localhost:8080/fedora/risearch');
  $url .= "?type=tuples&flush=TRUE&format=Sparql&lang=itql&stream=on&query=". $query_string;
  $content = do_curl($url);
  
  $results = simplexml_load_string($content);
  
  $object_info = array();
  foreach ($results->results->result AS $result) {
    $pid = (string) $result->object['uri'][0];
    $pid = preg_replace('/^info:fedora\//', '', $pid);
  }
  drupal_goto('fedora/repository/' . $pid, array('conference' => $conf_pid, 'contribution' => $con_pid ,'type' => $document), 'add-tab');
}