<?php

function dtu_conference_list() {
  module_load_include('inc', 'fedora_repository', 'api/fedora_item');
  
  $conferences = dtu_get_conferences();
  
  // edit, delete, hide, contributions
  $header = array('', t('Title'), t('Year'), '', t('Program'), t('Proceedings'));
  $rows = array();
  foreach ($conferences AS $conference) {
    $item = new Fedora_Item($conference['pid']);
    $mxe = $item->get_datastream_dissemination('MXE');
    $mxe_xml = simplexml_load_string($mxe);
    
    $year = (string) $mxe_xml->date->year;
    
    $obj_link = l($item->objectProfile->objLabel, 'fedora/repository/' . $conference['pid']);
    $edit_link = l(t('Edit'), 'fedora/repository/' . $conference['pid'], array('query' => array('add_tab' => 'true'), 'fragment' => 'tabset-1-tab-2'));
    $delete_link = l(t('Delete'), 'admin/conference/' . $conference['pid'] . '/delete');
    $hide_link = l(t('Hide'), 'admin/conference/' . $conference['pid'] . '/hide');
    $contributions_link = l(t('Contributions'), 'admin/conference/' . $conference['pid'] . '/contributions');
    
    $program = $mxe_xml->xpath('//documents/document[@role="program"]');
    
    if ($program) {
      // Edit link
      $prog_link = l(t('Edit'), 'fedora/repository/' . (string)$program[0]->attributes()->id, array('query' => array('add_tab' => 'true'), 'fragment' => 'tabset-1-tab-2'));
    }
    else {
      // Add link, send to the document sub-collection menu handler to avoid look-up here
      $prog_link = l(t('Add'), 'admin/conference/' . $conference['pid'] . '/document/program');
    }
    
    $proceedings = $mxe_xml->xpath('//documents/document[@role="proceedings"]');
    
    if ($proceedings) {
      // Edit link
      $proc_link = l(t('Edit'), 'fedora/repository/' . (string) $proceedings[0]->attributes()->id, array('query' => array('add_tab' => 'true'), 'fragment' => 'tabset-1-tab-2'));
    }
    else {
      // Add link, send to the document sub-collection menu handler to avoid look-up here
      $proc_link = l(t('Add'), 'admin/conference/' . $conference['pid'] . '/document/proceedings');
    }
    
    //$prog_link = l(t('Modify'), 'admin/conference/' . $conference['pid'] . '/edit/program');
    //$proc_link = l(t('Modify'), 'admin/conference/' . $conference['pid'] . '/edit/proceedings');
    
    $rows[] = array('', $obj_link, $year, $edit_link . ' | ' . $delete_link . ' | ' . $contributions_link, $prog_link, $proc_link);
  }
  
  // Sort conferences by year
  $year = array();
  foreach ($rows AS $row => $values) {
    $year[] = $values[2];
  }
  array_multisort($year, SORT_DESC, $rows);
  
  
  $conferences_table = theme('table', $header, $rows);
  $add_conference = l(t('Add conference'), 'fedora/repository/' . CONFERENCE_COLLECTION_PID, array('query' => array('add_tab' => 'true'), 'fragment' => 'add-tab'));
  
  return theme('dtu_conference_admin_list', $conferences_table, $add_conference);
}

function dtu_conference_list_form(&$form_state) {
  $form = array();
  
  return $form;
}

function dtu_conference_delete_form(&$form_state, $pid) {
  module_load_include('inc', 'fedora_repository', 'api/fedora_item');
  $item = new Fedora_Item($pid);
  
  $form = array();
  
  $form['pid'] = array(
    '#type' => 'value',
    '#value' => $pid,
  );
  
  return confirm_form($form, t('Delete conference:') . ' ' . $item->objectProfile->objLabel, 'admin/conference/list', t('This will delete the conference and its related documents.'), t('Delete'), t('Cancel'));
}

// Delete the object and its child documents
function dtu_conference_delete_form_submit($form, &$form_state) {
  if (user_access('delete conference')) {
    dtu_delete_conference($form_state['values']['pid'], TRUE);
    drupal_set_message(t('Conference deleted'));
  }
  else {
    drupal_set_message(t('Permission denied'));
  }
  drupal_goto('admin/conference/list');
}

//admin/conference/%/document/%
function dtu_conference_document_form_redirect($conf_pid, $document) {
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
  drupal_goto('fedora/repository/' . $pid, array('conference' => $conf_pid, 'type' => $document), 'add-tab');
}