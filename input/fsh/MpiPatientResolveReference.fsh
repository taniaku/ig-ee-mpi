Instance: PatientResolveReferenceNotFoundIssue
InstanceOf: OperationOutcome
Description: "Issue returned when the identifier system is allowed, but no patient was found"
Usage: #inline

* text.status = #additional
* text.div = """
<div xmlns="http://www.w3.org/1999/xhtml">
  <p><b>Severity:</b> warning</p>
  <p><b>Code:</b> not-found</p>
  <p><b>Details.coding.system:</b> https://mpi.tehik.ee</p>
  <p><b>Details.coding.code:</b> MPI-021</p>
  <p><b>Details.text:</b> Patsiendi identifikaatorit ei leitud</p>
</div>
"""
* issue[0].severity = #warning
* issue[0].code = #not-found
* issue[0].details.coding[0].system = $mpi
* issue[0].details.coding[0].code = #MPI-021
* issue[0].details.text = "Patsiendi identifikaatorit ei leitud"


Instance: PatientResolveReferenceInvalidSystemIssue
InstanceOf: OperationOutcome
Description: "Issue returned when the identifier system is not in the patsiendi-identifikaatorite-domeen value set"
Usage: #inline

* text.status = #additional
* text.div = """
<div xmlns="http://www.w3.org/1999/xhtml">
  <p><b>Severity:</b> error</p>
  <p><b>Code:</b> invalid</p>
  <p><b>Details.coding.system:</b> https://mpi.tehik.ee</p>
  <p><b>Details.coding.code:</b> MPI-067</p>
  <p><b>Details.text:</b> Patsiendi identifikaatori süsteem https://example.com/unknown-system ei ole lubatud</p>
</div>
"""
* issue[0].severity = #error
* issue[0].code = #invalid
* issue[0].details.coding[0].system = $mpi
* issue[0].details.coding[0].code = #MPI-067
* issue[0].details.text = "Patsiendi identifikaatori süsteem https://example.com/unknown-system ei ole lubatud"


Instance: PatientResolveReferenceExample
InstanceOf: Parameters
Description: "Example of Patient/$resolve-reference response: first identifier is resolved to a patient reference, second identifier is not found, third identifier has a system that is not allowed"
Usage: #example
* id = "patient-resolve-reference-example"

* parameter[0].name = "match"
* parameter[0].part[0].name = "identifier"
* parameter[0].part[0].valueIdentifier.system = "https://fhir.ee/sid/pid/est/ni"
* parameter[0].part[0].valueIdentifier.value = "37302102711"
* parameter[0].part[1].name = "patient"
* parameter[0].part[1].valueReference.reference = "Patient/pat1"

* parameter[1].name = "match"
* parameter[1].part[0].name = "identifier"
* parameter[1].part[0].valueIdentifier.system = "https://fhir.ee/sid/pid/est/ni"
* parameter[1].part[0].valueIdentifier.value = "49010012345"
* parameter[1].part[1].name = "issue"
* parameter[1].part[1].resource = PatientResolveReferenceNotFoundIssue

* parameter[2].name = "match"
* parameter[2].part[0].name = "identifier"
* parameter[2].part[0].valueIdentifier.system = "https://example.com/unknown-system"
* parameter[2].part[0].valueIdentifier.value = "12345678901"
* parameter[2].part[1].name = "issue"
* parameter[2].part[1].resource = PatientResolveReferenceInvalidSystemIssue
