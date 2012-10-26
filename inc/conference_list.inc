<?php

function dtu_render_conference_block() {
  module_load_include('inc', 'fedora_repository', 'api/fedora_item');

  $conferences = dtu_get_conferences();

  $header = array(t('Year'), t('Logo'), t('Short Title'), t('Title'));
  $rows = array();
  foreach ($conferences AS $conference) {
    $item = new Fedora_Item($conference['pid']);
    $mxe = $item->get_datastream_dissemination('MXE');
    $mxe_xml = simplexml_load_string($mxe);

    $year = (string) $mxe_xml->date->year;
    $abbrev_title = (string) $mxe_xml->title->original->short;

    $link = 'fedora/repository/' . $conference['pid'];

    if (array_key_exists('TN', $item->datastreams)) {
      $tn = theme_image('fedora/repository/' . $conference['pid'] . '/TN', t('Logo'), t('Logo'), NULL, FALSE);
    }
    else {
      $tn = '';
    }

    $abbrev_link = l($abbrev_title, $link);
    $title_link = l($item->objectProfile->objLabel, $link);

    $rows[] = array($year, $tn, $abbrev_link, $title_link);
  }

  $year = array();
  foreach ($rows AS $row => $values) {
    $year[] = $values[0];
  }
  array_multisort($year, SORT_DESC, $rows);

  $conferences_table = theme('table', $header, $rows);
  return theme('dtu_conferences_list', $conferences_table);
}